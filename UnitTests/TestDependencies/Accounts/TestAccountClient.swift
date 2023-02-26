import Foundation
import Dependencies

extension AccountClient {
    static let test = AccountClient(getTransactions: { _,_,accessToken in
        let launchArgs = ProcessInfo.processInfo.arguments
        let transactions = [
            "myToken": TestHelpers.Transactions.transaction,
            "tokenWithFeed": TestHelpers.Transactions.transactionWithItem
        ]
        
        guard let transaction = transactions[accessToken] else {
            throw AccountClientError.invalidAccount
        }
        
        // For UI Tests
        if launchArgs.contains("AccountServiceDown") {
            throw AccountClientError.other
        }
        
        if launchArgs.contains("AccountServiceWithTransaction") {
            return TestHelpers.Transactions.transactionWithItem
        }
        
        if launchArgs.contains("AccountServiceWithOnlyInTransactions") {
            return TestHelpers.Transactions.transactionWithItemWithOnlyInTransactions
        }
        
        return transaction
    }, roundUp: { amounts in
        // Use the real rounding service so we can test rounding
        return try roundingService.batchRoundUp(amounts)
    })
}

extension AccountClient: TestDependencyKey {
    static let testValue = AccountClient.test
}
