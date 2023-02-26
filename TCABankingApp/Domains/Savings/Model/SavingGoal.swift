struct SavingGoal: Codable, Equatable, Identifiable {
    let savingsGoalUid: String
    var id: String {
        savingsGoalUid
    }
    let name: String
    let target: Amount
    let totalSaved: Amount
    let savedPercentage: Int
}

struct SavingGoalResponse: Codable, Equatable {
    let savingsGoalList: [SavingGoal]
}
