import Foundation
import Network

public final class ServerDiscovery: @unchecked Sendable {
    private var browsers: [NWBrowser] = []

    public init() {}

    public func startScanning() -> AsyncStream<DiscoveredServer> {
        AsyncStream { continuation in
            let jellyfinBrowser = makeBrowser(service: "_jellyfin._tcp", kind: .jellyfin, continuation: continuation)
            let embyBrowser = makeBrowser(service: "_emby._tcp", kind: .emby, continuation: continuation)
            let plexBrowser = makeBrowser(service: "_plexmediasvr._tcp", kind: .plex, continuation: continuation)

            browsers = [jellyfinBrowser, embyBrowser, plexBrowser]
            browsers.forEach { $0.start(queue: .global()) }

            continuation.onTermination = { [weak self] _ in
                self?.stopScanning()
            }
        }
    }

    public func stopScanning() {
        browsers.forEach { $0.cancel() }
        browsers = []
    }

    public func pingServer(at url: URL, timeout: TimeInterval = 5) async -> ServerKind? {
        let client = HTTPClient(baseURL: url, timeoutInterval: timeout)

        if await client.ping(path: "/System/Info") {
            return .jellyfin
        }

        if await client.ping(path: "/emby/System/Info") {
            return .emby
        }

        if await client.ping(path: "/identity") {
            return .plex
        }

        return nil
    }

    private func makeBrowser(service: String, kind: ServerKind, continuation: AsyncStream<DiscoveredServer>.Continuation) -> NWBrowser {
        NWBrowser(
            for: .bonjour(type: service, domain: "local"),
            using: .tcp
        ).apply {
            $0.browseResultsChangedHandler = { results, _ in
                for result in results {
                    switch result.endpoint {
                    case .service(let name, _, _, _):
                        let server = DiscoveredServer(
                            name: name,
                            kind: kind,
                            endpoint: result.endpoint
                        )
                        continuation.yield(server)
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
}

public struct DiscoveredServer: Identifiable {
    public let id = UUID()
    public let name: String
    public let kind: ServerKind
    public let endpoint: NWEndpoint
}

extension NWBrowser {
    fileprivate func apply(_ block: (NWBrowser) -> Void) -> NWBrowser {
        block(self)
        return self
    }
}
