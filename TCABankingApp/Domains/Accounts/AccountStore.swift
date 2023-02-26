import Foundation
import ComposableArchitecture 

struct AccountStore: ReducerProtocol  {
    @Dependency(\.accountClient) var accountClient    
    
    private enum AccountStoreID {}
    
    struct State: Equatable {
        var user: User
        var selectedAccount: Account?
        var transactions: Transaction?
        var endDate: Date = Date()
        var roundUpAmount: Amount?
        
        var isSheetPresented: Bool {
            return selectedAccount != nil
        }
        
        var loading: Bool = false
        var error: String?

        var savingState: SavingsStore.State? {
            guard let account = selectedAccount,
                  let roundUpAmount = roundUpAmount else {
                return nil
            }
            
            return SavingsStore.State(user: user,
                                      selectedAccount: account,
                                      roundUp: roundUpAmount,
                                      goals: [SavingGoal]())
        }
    }

    enum Action: Equatable {
        case pickAccount(Account)
        case roundUp(Transaction)
        case dateChange(Date)
        
        // Requests
        case requestTransactions(Account)        
        
        // Responses
        case gotResponseForTransactions(TaskResult<Transaction>)        
        
        // Side Effects
        case setSheet(isPresented: Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        // MARK: Picking an account
        case .pickAccount(let account):
            state.selectedAccount = account
            return .none
            
        // MARK: Request for Transaction
        case .requestTransactions(let account):
            state.error = nil
            state.loading = true
            
            guard let accessToken = state.user.accessToken else {
                state.error = AccountClientError.other.errorDescription
                return .none
            }
            
            let weekInterval = state.endDate.weekInterval()
            
            return .task {
                await .gotResponseForTransactions(TaskResult {
                    return try await self
                        .accountClient
                        .getTransactions(account.accountUid,
                                         weekInterval,
                                         accessToken)
                })
            }
            .cancellable(id: AccountStoreID.self)
            
        // MARK: Responses for Transaction
        case .gotResponseForTransactions(.success(let transactions)):
            // For round up we only want to should outgoing payments that are settled.
            let settledFeedItems = transactions
                .feedItems
                .filter{ $0.direction == .out && $0.status == "SETTLED" }
            
            let newTransaction = Transaction(id: transactions.id,
                                             feedItems: settledFeedItems)
            state.transactions = newTransaction

            state.loading = false
            return .task {
                return .roundUp(newTransaction)
            }
            
        case .gotResponseForTransactions(.failure(let error)):
            state.loading = false
            state.error = error.localizedDescription
            return .none
            
        // MARK: Setting Sheet
        case .setSheet(isPresented: false):
            state.selectedAccount = nil
            state.transactions = nil
            return .none
        case .setSheet(isPresented: true):            
            guard let selectedAccount = state.selectedAccount else {
                return .none
            }
                        
            return .task {
                return .requestTransactions(selectedAccount)
            }
            .cancellable(id: AccountStoreID.self)
            
        // MARK: Round Up
        case .roundUp(let transaction):
            do {
                state.roundUpAmount = try accountClient.roundUp(transaction
                    .feedItems
                    .map { $0.amount })
            } catch {
                state.roundUpAmount = nil                
                state.error = "Failed to get round up for this time"
            }
            return .none
        case .dateChange(let date):
            state.endDate = date
            guard let account = state.selectedAccount else {                
                return .none
            }
            return .task {
                .requestTransactions(account)
            }
        }
    }
}
