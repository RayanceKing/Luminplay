import Foundation

public final class HTTPClient: @unchecked Sendable {
    private let session: URLSession
    private let baseURL: URL
    private var authHeaders: [String: String]
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        authHeaders: [String: String] = [:],
        timeoutInterval: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.authHeaders = authHeaders
        self.decoder = JSONDecoder()

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }

    public func setAuthHeader(key: String, value: String) {
        authHeaders[key] = value
    }

    public func removeAuthHeader(key: String) {
        authHeaders.removeValue(forKey: key)
    }

    public func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        let data = try await request("GET", path: path, queryItems: queryItems)
        return try decoder.decode(T.self, from: data)
    }

    public func post<T: Decodable>(_ path: String, body: Data? = nil) async throws -> T {
        let data = try await request("POST", path: path, body: body)
        return try decoder.decode(T.self, from: data)
    }

    public func postVoid(_ path: String, body: Data? = nil) async throws {
        _ = try await request("POST", path: path, body: body)
    }

    public func getData(_ path: String, queryItems: [URLQueryItem] = []) async throws -> Data {
        try await request("GET", path: path, queryItems: queryItems)
    }

    public func ping(path: String = "/") async -> Bool {
        do {
            _ = try await request("GET", path: path, retryCount: 0)
            return true
        } catch {
            return false
        }
    }

    private func request(
        _ method: String,
        path: String,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        retryCount: Int = 1
    ) async throws -> Data {
        var url = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            url.queryItems = queryItems
        }

        var request = URLRequest(url: url.url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        for (key, value) in authHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPClientError.invalidResponse
            }

            if (200...299).contains(httpResponse.statusCode) {
                return data
            }

            if retryCount > 0, httpResponse.statusCode >= 500 {
                try await Task.sleep(for: .seconds(1))
                return try await self.request(method, path: path, queryItems: queryItems, body: body, retryCount: retryCount - 1)
            }

            throw HTTPClientError.httpError(statusCode: httpResponse.statusCode, data: data)
        } catch let error as HTTPClientError {
            throw error
        } catch {
            throw HTTPClientError.networkError(error)
        }
    }
}

public enum HTTPClientError: Error {
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case networkError(Error)
}
