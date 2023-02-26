import Foundation
import Dependencies

extension UserClient {
    static let test = UserClient(
        getUser: { accessToken in
            let launchArgs = ProcessInfo.processInfo.arguments
            var validUsers: [String: User] = [
                "myToken": TestHelpers.Users.user
            ]
            
            if launchArgs.contains("UserServiceDown") {
                throw UserClientError.other("User Service Down!")
            }
            
            if launchArgs.contains("UserWithSingleAccount") {
                return TestHelpers.Users.userWithFeedItems
            }
            
            if let authenticatedUser = validUsers[accessToken] {
                return authenticatedUser
            } else {
                throw UserClientError.invalidUser
            }
    })
}

extension UserClient: TestDependencyKey {
    static let testValue = UserClient.test
}
