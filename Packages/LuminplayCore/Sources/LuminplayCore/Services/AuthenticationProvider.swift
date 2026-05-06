import Foundation

public protocol AuthenticationProviding {
    func authenticate(server: ServerConnection, username: String, password: String) async throws -> String
    func validateToken(server: ServerConnection, token: String) async throws -> Bool
}

public struct JellyfinAuthProvider: AuthenticationProviding {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public func authenticate(server: ServerConnection, username: String, password: String) async throws -> String {
        struct AuthRequest: Encodable {
            let username: String
            let pw: String
            let password: String

            init(username: String, password: String) {
                self.username = username
                self.pw = password
                self.password = password
            }
        }

        struct AuthResponse: Decodable {
            let accessToken: String
        }

        let body = try JSONEncoder().encode(AuthRequest(username: username, password: password))
        let response: AuthResponse = try await client.post("/Users/AuthenticateByName", body: body)
        return response.accessToken
    }

    public func validateToken(server: ServerConnection, token: String) async throws -> Bool {
        client.setAuthHeader(key: "X-Emby-Token", value: token)
        return await client.ping(path: "/System/Info")
    }
}

public struct EmbyAuthProvider: AuthenticationProviding {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public func authenticate(server: ServerConnection, username: String, password: String) async throws -> String {
        struct AuthRequest: Encodable {
            let username: String
            let pw: String
            let password: String

            init(username: String, password: String) {
                self.username = username
                self.pw = password
                self.password = password
            }
        }

        struct AuthResponse: Decodable {
            let accessToken: String
        }

        let body = try JSONEncoder().encode(AuthRequest(username: username, password: password))
        let response: AuthResponse = try await client.post("/Users/AuthenticateByName", body: body)
        return response.accessToken
    }

    public func validateToken(server: ServerConnection, token: String) async throws -> Bool {
        client.setAuthHeader(key: "X-Emby-Token", value: token)
        return await client.ping(path: "/System/Info")
    }
}

public struct PlexAuthProvider: AuthenticationProviding {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public func authenticate(server: ServerConnection, username: String, password: String) async throws -> String {
        struct PlexAuthResponse: Decodable {
            let user: PlexUser

            struct PlexUser: Decodable {
                let authToken: String

                enum CodingKeys: String, CodingKey {
                    case authToken = "auth_token"
                }
            }
        }

        let body = "user[login]=\(username)&user[password]=\(password)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .data(using: .utf8)

        let response: PlexAuthResponse = try await client.post(
            "https://plex.tv/api/v2/users/sign_in",
            body: body
        )
        return response.user.authToken
    }

    public func validateToken(server: ServerConnection, token: String) async throws -> Bool {
        client.setAuthHeader(key: "X-Plex-Token", value: token)
        return await client.ping(path: "/identity")
    }
}
