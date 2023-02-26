import Foundation
import ComposableArchitecture

struct UserClient {
    @Dependency (\.appContext) static var appContext
    
    /// Return the current user. Use to retrieve the root item.
    var getUser: @Sendable (String) async throws -> User
}

extension UserClient {
    static let live = Self(
        getUser: { accessToken in
            guard let getUserUrl = try? appContext
                .apiConfiguration
                .getURL(.user)
            else {
                throw UserClientError.other("Oops something went wrong when talking to the server. Try updating your app.")
            }
            
            guard !accessToken.isEmpty else {
                throw UserClientError.invalidUser
            }
            
            var request = URLRequest(url: getUserUrl)
            request.addValue("Bearer \(accessToken)",
                             forHTTPHeaderField: "Authorization")
            request.addValue("application/json",
                             forHTTPHeaderField: "Content-Type")
            
            let (data, _) = try await appContext
                .httpClient
                .data(request)
            
            do {
                var user = try appContext
                    .jsonCoders
                    .decoder(.iso8601)
                    .decode(User.self,
                            from: data)
                
                user.accessToken = accessToken
                return user
            } catch let error {
                throw UserClientError.other(error.localizedDescription)
            }
        }
    )
}

extension UserClient: DependencyKey {
    static let liveValue = UserClient.live
}

extension DependencyValues {
  var userClient: UserClient {
    get { self[UserClient.self] }
    set { self[UserClient.self] = newValue }
  }
}
