import XCTest
import ComposableArchitecture
@testable import TCABankingApp

@MainActor
final class AccountClientTests: XCTestCase {
    func testGetTransactionsForAccount() async {
        let user = TestHelpers.Users.userWithFeedItems
        let account = TestHelpers.Accounts.account
        let transaction = TestHelpers.Transactions.transactionWithItem
        
        let store = TestStore(
            initialState: AccountStore.State(user: user),
            reducer: AccountStore()
        )

        // Using the production Account Client
        store.dependencies.roundingService = RoundingService(batchRoundUp: { amounts in
            return Amount(currency: .gbp, minorUnits: 0)
        })
        
        store.dependencies.uuidService = .testValue
        store.dependencies.accountClient = .liveValue

        store.dependencies.apiConfiguration = APIConfiguration(getURL: { endpoint in
           URL(string: "http://TESTING")!
        })

        // Mock out the API Response
        store.dependencies.httpClient = HTTPClient(data: { request in
            guard let response =
            """
            {
              "feedItems": [
                {
                  "feedItemUid": "9b12e01b-b760-4c3c-a74a-41d2d7f7251c",
                  "categoryUid": "6a1e138d-ff0a-40fb-8a56-b6864a4fecf9",
                  "amount": {
                    "currency": "GBP",
                    "minorUnits": 50000
                  },
                  "sourceAmount": {
                    "currency": "GBP",
                    "minorUnits": 50000
                  },
                  "direction": "IN",
                  "updatedAt": "2023-01-12T18:58:52.853Z",
                  "transactionTime": "2023-01-12T18:58:52.000Z",
                  "settlementTime": "2023-01-12T18:58:52.000Z",
                  "source": "FASTER_PAYMENTS_IN",
                  "status": "SETTLED",
                  "counterPartyType": "SENDER",
                  "counterPartyName": "Faster payment",
                  "counterPartySubEntityName": "",
                  "counterPartySubEntityIdentifier": "600522",
                  "counterPartySubEntitySubIdentifier": "20026854",
                  "reference": "Ref: 4303802696",
                  "country": "GB",
                  "spendingCategory": "INCOME",
                  "hasAttachment": false,
                  "hasReceipt": false,
                  "batchPaymentDetails": null
                }
            ]
            }
            """.data(using: .utf8) else {
                XCTFail("Failed to create data for JSON string")
                return (Data(), URLResponse())
            }
            return (response, URLResponse())
        })

        await store.send(.requestTransactions(account)) {
            $0.loading = true
        }
        
        await store.receive(.gotResponseForTransactions(.success(transaction))) {
            $0.transactions = transaction
            $0.loading = false
        }
        
        await store.receive(.roundUp(transaction)) {
            $0.roundUpAmount = Amount(currency: .gbp, minorUnits: 0)
        }
    }
    
    
    func testFailureToEncodeAccount() async {
        guard let badData = "Some String".data(using: .utf8) else {
            return XCTFail(TestHelpers.testSetupFailed)
        }

        let expectedError = AccountClientError.other

        let user = TestHelpers.Users.userWithFeedItems
        let account = TestHelpers.Accounts.account
        let store = TestStore(
            initialState: AccountStore.State(user: user),
            reducer: AccountStore()
        )

        // Using the production Account Client
        store.dependencies.accountClient = .liveValue

        store.dependencies.apiConfiguration = APIConfiguration(getURL: { endpoint in
           URL(string: "http://TESTING")!
        })

        store.dependencies.httpClient = HTTPClient(data: { request in
            return (badData, URLResponse())
        })

        await store.send(.requestTransactions(account)) {
            $0.loading = true
        }

        await store.receive(.gotResponseForTransactions(.failure(expectedError))) {
            $0.error = expectedError.localizedDescription
            $0.loading = false
        }
    }

    func testGetAccountWithNoAuth() async {
        guard let badData = "Some String".data(using: .utf8) else {
            return XCTFail(TestHelpers.testSetupFailed)
        }

        let user = TestHelpers.Users.userWithNoAuth
        let account = TestHelpers.Accounts.account
        let store = TestStore(
            initialState: AccountStore.State(user: user),
            reducer: AccountStore()
        )

        // Using the production Account Client
        store.dependencies.accountClient = .liveValue

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

