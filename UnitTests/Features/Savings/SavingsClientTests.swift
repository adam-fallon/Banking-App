import XCTest
import ComposableArchitecture
@testable import TCABankingApp

@MainActor
final class SavingsClientTests: XCTestCase {
    func testExecRoundUp() async {
        let user = TestHelpers.Users.userWithFeedItems
        let account = TestHelpers.Accounts.account
        let roundUp = Amount(currency: .gbp, minorUnits: 1)
        let roundUpResponse = SavingsResponse(transferUid: "c1a4f72d-ea12-40c7-bd3f-4640c51398de", success: true)
        let goals = [TestHelpers.Savings.goal]
        let goalResponse = TestHelpers.Savings.savingsGoalResponse
        
        let store = TestStore(
            initialState: SavingsStore.State(user: user, selectedAccount: account, roundUp: roundUp, goals: goals),
            reducer: SavingsStore()
        )
        
        store.dependencies.roundingService = RoundingService(batchRoundUp: { amounts in
            return Amount(currency: .gbp, minorUnits: 99)
        })
        
        store.dependencies.uuidService = .testValue
        
        // Using the production Savings Client
        store.dependencies.savingsClient = .liveValue
        
        store.dependencies.apiConfiguration = APIConfiguration(getURL: { endpoint in
            URL(string: "http://TESTING")!
        })
        
        // Mock out the API Response
        store.dependencies.httpClient = savingGoalsMockResponse
        
        await store.send(.getGoals) {
            $0.loading = true
        }
        
        await store.receive(.gotResponseForGoals(.success(goalResponse))) {
            $0.selectedGoal = goalResponse.savingsGoalList.first
            $0.loading = false
        }
        
        store.dependencies.httpClient = roundUpMockResponse
        
        await store.send(.requestSaveRoundUp) {
            $0.loading = true
        }
        
        await store.receive(.gotResponseForRoundUp(.success(roundUpResponse))) {
            $0.loading = false
            $0.goalSaved = true
        }
    }
 
    func testRoundUpWithNoAuth() async {
        guard let badData = "Some String".data(using: .utf8) else {
            return XCTFail(TestHelpers.testSetupFailed)
        }

        let user = TestHelpers.Users.userWithNoAuth
        let account = TestHelpers.Accounts.account
        let store = TestStore(
            initialState: AccountStore.State(user: user),
            reducer: AccountStore()
        )

        // Using the production Savings Client
        store.dependencies.savingsClient = .liveValue

        store.dependencies.apiConfiguration = APIConfiguration(getURL: { endpoint in
           URL(string: "http://TESTING")!
        })

        store.dependencies.httpClient = HTTPClient(data: { request in
            return (badData, URLResponse())
        })

        await store.send(.requestTransactions(account)) {
            $0.loading = true
            $0.error = "Oops, something went wrong. Please try again."
        }
    }
}

extension SavingsClientTests {
    var savingGoalsMockResponse: HTTPClient {
        HTTPClient(data: { request in
            guard let response =
            """
            {
              "savingsGoalList": [
                {
                  "savingsGoalUid": "af69dc42-9d89-4ded-83a9-e6e921ec9223",
                  "name": "TCABankingApp",
                  "target": {
                    "currency": "GBP",
                    "minorUnits": 10000
                  },
                  "totalSaved": {
                    "currency": "GBP",
                    "minorUnits": 5123
                  },
                  "savedPercentage": 51
                }
              ]
            }
            """.data(using: .utf8) else {
                XCTFail("Failed to create data for JSON string")
                return (Data(), URLResponse())
            }
            return (response, URLResponse())
        })
    }
    
    var roundUpMockResponse: HTTPClient {
        HTTPClient(data: { request in
            guard let response =
            """
            {
                "transferUid": "c1a4f72d-ea12-40c7-bd3f-4640c51398de",
                "success": true,
                "errors": []
            }
            """.data(using: .utf8) else {
                XCTFail("Failed to create data for JSON string")
                return (Data(), URLResponse())
            }
            return (response, URLResponse())
        })
    }
}
