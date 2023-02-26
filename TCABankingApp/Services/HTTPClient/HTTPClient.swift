import Foundation
import ComposableArchitecture

struct HTTPClient {
    var data: (URLRequest) async throws -> (Data, URLResponse)
}

extension HTTPClient {
    static let live = HTTPClient(
        data: { request in
            return try await URLSession.shared.data(for: request)
        }
    )
}

extension HTTPClient {
    static let test = HTTPClient(
        data: { request in
            let launchArgs = ProcessInfo.processInfo.arguments
            return (Data(), URLResponse())
        }
    )
}

extension HTTPClient: DependencyKey {
    static let liveValue = HTTPClient.live
}

extension HTTPClient: TestDependencyKey {
    static let testValue = HTTPClient.test
}

extension DependencyValues {
  var httpClient: HTTPClient {
    get { self[HTTPClient.self] }
    set { self[HTTPClient.self] = newValue }
  }
}
