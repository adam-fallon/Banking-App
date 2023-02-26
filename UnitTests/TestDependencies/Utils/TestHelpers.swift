import Foundation

public struct TestHelpers {
    static let testSetupFailed = "Test setup incorrect, missing rootItem for user"
    
    struct Users {
        static let user: User = User(
            accounts: [Account](),             
            accessToken: "myToken"
        )

        
        static let userWithFeedItems: User = User(
            accounts: [Accounts.account],
            accessToken: "tokenWithFeed"
        )
        
        static let userWithNoAuth: User = User(
            accounts: [Account]()
        )
    }
    
    struct Transactions {
        static let transaction: Transaction = Transaction(feedItems: [FeedItem]())
        static let defaultTransactionUid = "BA770B5F-8E35-42AF-AF41-9E4F06377721"
        static let transactionWithItemWithOnlyInTransactions: Transaction = Transaction(id: UUID(uuidString: defaultTransactionUid) ?? UUID(),
                                                                                        feedItems: [FeedItems.feedItemOnlyIn])
        static let transactionWithItem: Transaction = Transaction(id: UUID(uuidString: defaultTransactionUid) ?? UUID(),
                                                                  feedItems: [FeedItems.feedItem])
    }
    
    struct Accounts {
        static let account: Account = Account(accountUid: "accountUid",
                                              accountType: "accountType",
                                              defaultCategory: "defaultCategory",
                                              currency: "currency",
                                              createdAt: "createAt",
                                              name: "name")
    }
    
    struct FeedItems {
        
        static let feedItem: FeedItem = FeedItem(
            feedItemUid: "9b12e01b-b760-4c3c-a74a-41d2d7f7251c",
            categoryUid: "6a1e138d-ff0a-40fb-8a56-b6864a4fecf9",
            amount: Amount(currency: Currency.gbp, minorUnits: 1),
            sourceAmount: Amount(currency: Currency.gbp, minorUnits: 1),
            direction: Direction.out,
            updatedAt: "2023-01-12T18:58:52.853Z",
            transactionTime: "2023-01-12T18:58:52.000Z",
            settlementTime: "2023-01-12T18:58:52.000Z",
            source: "FASTER_PAYMENTS_OUT",
            status: "SETTLED",
            counterPartyType: CounterPartyType.sender,
            counterPartyName: "Faster payment",
            counterPartySubEntityName: "",
            counterPartySubEntityIdentifier: "600522",
            counterPartySubEntitySubIdentifier: "20026854",
            reference: "Ref: 4303802696",
            country: Country.gb,
            spendingCategory: "FUEL",
            hasAttachment: false,
            hasReceipt: false,
            batchPaymentDetails: nil,
            transactingApplicationUserUid: nil,
            counterPartyUid: nil,
            counterPartySubEntityUid: nil
        )
        
        static let feedItemOnlyIn: FeedItem = FeedItem(
            feedItemUid: "9b12e01b-b760-4c3c-a74a-41d2d7f7251c",
            categoryUid: "6a1e138d-ff0a-40fb-8a56-b6864a4fecf9",
            amount: Amount(currency: Currency.gbp, minorUnits: 50000),
            sourceAmount: Amount(currency: Currency.gbp, minorUnits: 50000),
            direction: Direction.directionIN,
            updatedAt: "2023-01-12T18:58:52.853Z",
            transactionTime: "2023-01-12T18:58:52.000Z",
            settlementTime: "2023-01-12T18:58:52.000Z",
            source: "FASTER_PAYMENTS_IN",
            status: "SETTLED",
            counterPartyType: CounterPartyType.sender,
            counterPartyName: "Faster payment",
            counterPartySubEntityName: "",
            counterPartySubEntityIdentifier: "600522",
            counterPartySubEntitySubIdentifier: "20026854",
            reference: "Ref: 4303802696",
            country: Country.gb,
            spendingCategory: "FUEL",
            hasAttachment: false,
            hasReceipt: false,
            batchPaymentDetails: nil,
            transactingApplicationUserUid: nil,
            counterPartyUid: nil,
            counterPartySubEntityUid: nil
        )
    }
    
    struct Savings {
        static let goal = SavingGoal(savingsGoalUid: "af69dc42-9d89-4ded-83a9-e6e921ec9223",
                                     name: "TCABankingApp",
                                     target: Amount(currency: .gbp, minorUnits: 10000),
                                     totalSaved: Amount(currency: .gbp, minorUnits: 5123),
                                     savedPercentage: 51)
        static let savingsGoalResponse = SavingGoalResponse(savingsGoalList: [Savings.goal])
    }
}
