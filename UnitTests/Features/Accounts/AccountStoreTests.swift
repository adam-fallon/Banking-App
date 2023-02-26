import XCTest
import ComposableArchitecture
@testable import TCABankingApp

@MainActor
final class AccountStoreTests: XCTestCase {
    let underTest = AccountStore()
    
    func testPickAccount() async {
        // Given a test store that returns a valid user
        let user = TestHelpers.Users.user
        let account = TestHelpers.Accounts.account
        
        let store = TestStore(
            initialState: AccountStore.State(user: user),
            reducer: AccountStore()
        )
        
        await store.send(.pickAccount(account)) {
            $0.selectedAccount = account
        }
    }
    
    func testRequestTransactions() async {
        // Given a test store that returns a valid user
        let user = TestHelpers.Users.userWithFeedItems
        let transaction = TestHelpers.Transactions.transactionWithItem
        let account = TestHelpers.Accounts.account
        
        let store = TestStore(
            initialState: AccountStore.State(user: user),
            reducer: AccountStore()
        )
        
        await store.send(.pickAccount(account)) {
            $0.selectedAccount = account
        }
        
        await store.send(.requestTransactions(account)) {
            $0.loading = true
        }
        
        await store.receive(.gotResponseForTransactions(.success(transaction))) {
            $0.loading = false
            $0.transactions = transaction
        }
        
        await store.receive(.roundUp(transaction)) {
            $0.roundUpAmount = Amount(currency: .gbp, minorUnits: 99)
        }
    }
    
    func testDismissingSheetClearsState() async {
        let user = TestHelpers.Users.userWithFeedItems
        let transaction = TestHelpers.Transactions.transactionWithItem
        let account = TestHelpers.Accounts.account
        
        let store = TestStore(
            initialState: AccountStore.State(user: user),
            reducer: AccountStore()
        )
        
        // When an event is sent to the store with a username and password
        await store.send(.pickAccount(account)) {
            $0.selectedAccount = account
        }
        
        await store.send(.setSheet(isPresented: true))
        
        await store.receive(.requestTransactions(account)) {
            $0.loading = true
        }
        
        await store.receive(.gotResponseForTransactions(.success(transaction))) {
            $0.transactions = transaction
            $0.loading = false
        }
        
        await store.receive(.roundUp(transaction)) {
            $0.roundUpAmount = Amount(currency: .gbp, minorUnits: 99)
        }
        
        // When the sheet is dismissed, state is cleared
        await store.send(.setSheet(isPresented: false)) {
            $0.selectedAccount = nil
            $0.transactions = nil
        }
    }
    
    func testRequestsTransactionsWithoutAccessToken() async {
        let userWithNoAuth = TestHelpers.Users.userWithNoAuth
        let account = TestHelpers.Accounts.account
        
        let store = TestStore(
            initialState: AccountStore.State(user: userWithNoAuth),
            reducer: AccountStore()
        )
        
        // When an event is sent to the store with a username and password
        await store.send(.pickAccount(account)) {
            $0.selectedAccount = account
        }
        
        await store.send(.setSheet(isPresented: true))
        
        // Then an error is thrown
        await store.receive(.requestTransactions(account)) {
            $0.loading = true
            $0.error = "Oops, something went wrong. Please try again."
        }
    }
}
