import ComposableArchitecture

struct SavingsStore: ReducerProtocol {
    @Dependency(\.savingsClient) var savingsClient
    
    private enum SavingsStoreID {}
    
    struct State: Equatable {
        var user: User?
        var selectedAccount: Account?
        var selectedGoal: SavingGoal?
        var roundUp: Amount?
        var goals: [SavingGoal] = []
        var loading: Bool = false
        var error: String?
        var goalSaved: Bool = false
    }
    
    enum Action: Equatable {
        case getGoals
        case gotResponseForGoals(TaskResult<SavingGoalResponse>)
        case requestSaveRoundUp
        case gotResponseForRoundUp(TaskResult<SavingsResponse>)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {            
        case .requestSaveRoundUp:
            state.error = nil
            state.loading = true

            guard let accessToken = state.user?.accessToken,
                  let accountUid = state.selectedAccount?.accountUid,
                  let roundUp = state.roundUp,
                  let selectedGoal = state.selectedGoal
                else {
                state.error = SavingsClientError.other.errorDescription
                return .none
            }
            
            return .task {
                await .gotResponseForRoundUp(TaskResult {
                    return try await self.savingsClient.saveRoundUp(accountUid,
                                                                    selectedGoal.savingsGoalUid,
                                                                    roundUp,
                                                                    accessToken)
                })
            }
            .cancellable(id: SavingsStoreID.self)
        case .gotResponseForRoundUp(.success(let savingsResponse)):
            state.loading = false
            
            if !savingsResponse.success {                
                state.error = "Oops something went wrong."
            }
            
            state.goalSaved = true
            
            return .none
            
        case .gotResponseForRoundUp(.failure(_)):
            state.loading = false            
            state.error = SavingsClientError.other.errorDescription
            return .none
        case .getGoals:
            state.loading = true
            guard let account = state.selectedAccount?.accountUid,
                    let accessToken = state.user?.accessToken
            else {
                state.error = "Couldn't get goals"
                return .none
            }
            
            return .task {
                await .gotResponseForGoals(TaskResult {
                    return try await self
                        .savingsClient
                        .getSavingGoals(account, accessToken)
                })
            }
            .cancellable(id: SavingsStoreID.self)
        case .gotResponseForGoals(.success(let goals)):
            state.loading = false
            state.goals = goals.savingsGoalList
            
            if let selectedGoal = goals.savingsGoalList.first {
                state.selectedGoal = selectedGoal
            }
            
            return .none
        case .gotResponseForGoals(.failure(let error)):
            state.loading = false
            state.error = error.localizedDescription
            return .none
        }
    }
}
