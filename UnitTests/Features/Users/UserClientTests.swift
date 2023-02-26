import XCTest
import ComposableArchitecture
@testable import TCABankingApp

@MainActor
final class UserClientTests: XCTestCase {    
    func testLogin() async {
        let user = TestHelpers.Users.user
        let store = TestStore(
            initialState: UserStore.State(),
            reducer: UserStore()
        )

        // Using the production Items Client
        store.dependencies.userClient = .live

        store.dependencies.apiConfiguration = APIConfiguration(getURL: { endpoint in
           URL(string: "http://TESTING")!
        })

        store.dependencies.httpClient = HTTPClient(data: { request in
            guard let response =
            """
            {
              "accounts": [
                {
                  "accountUid": "uuid",
                  "accountType": "PRIMARY",
                  "defaultCategory": "anotherUuid",
                  "currency": "GBP",
                  "createdAt": "2023-01-12T18:57:55.874Z",
                  "name": "Personal"
                }
              ]
            }
            """.data(using: .utf8) else {
                XCTFail("Failed to create data for JSON string")
                return (Data(), URLResponse())
            }
            return (response, URLResponse())
        })

        await store.send(.loadUser("myToken")) {
            $0.loading = true
        }

        await store.receive(.requestResponse(.success(user))) {
            $0.loading = false
            $0.user = user
        }
    }

    func testLoginFailsToEncodeUser() async {
        guard let badData = "Some String".data(using: .utf8) else {
            return XCTFail(TestHelpers.testSetupFailed)
        }

        let expectedError = UserClientError.other("Oops, something went wrong. Please try again.")

        let store = TestStore(
            initialState: UserStore.State(),
            reducer: UserStore()
        )

        // Using the production Items Client
        store.dependencies.userClient = .live

        store.dependencies.apiConfiguration = APIConfiguration(getURL: { endpoint in
           URL(string: "http://TESTING")!
        })

        store.dependencies.httpClient = HTTPClient(data: { request in
            return (badData, URLResponse())
        })

        await store.send(.loadUser("myToken")) {
            $0.loading = true
        }

        await store.receive(.requestResponse(.failure(expectedError))) {
            $0.errorReason = expectedError.localizedDescription
            $0.loading = false
        }
    }

    func testLoginWithEmptyValues() async {
        guard let badData = "Some String".data(using: .utf8) else {
            return XCTFail(TestHelpers.testSetupFailed)
        }

        let store = TestStore(
            initialState: UserStore.State(),
            reducer: UserStore()
        )
        
        let expectedError = UserClientError.other("Oops, something went wrong. Please try again.")

        // Using the production Items Client
        store.dependencies.userClient = .live

        store.dependencies.apiConfiguration = APIConfiguration(getURL: { endpoint in
           URL(string: "http://TESTING")!
        })

        store.dependencies.httpClient = HTTPClient(data: { request in
            return (badData, URLResponse())
        })

        await store.send(.loadUser("myToken")) {
            $0.loading = true
        }

        await store.receive(.requestResponse(.failure(expectedError))) {
            $0.errorReason = expectedError.localizedDescription
            $0.loading = false
        }
    }
}
