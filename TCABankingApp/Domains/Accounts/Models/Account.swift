// MARK: - Account
struct Account: Codable, Equatable, Identifiable {
    let accountUid, accountType, defaultCategory, currency: String
    let createdAt, name: String
    
    var id: String { self.accountUid }
}
