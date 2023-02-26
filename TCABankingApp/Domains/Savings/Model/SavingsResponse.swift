struct SavingsError: Codable {
    var description: String
    var message: String
}

struct SavingsResponse: Codable, Equatable {
    var transferUid: String
    var success: Bool
    var errors: [SavingsError]?
    
    static func == (lhs: SavingsResponse, rhs: SavingsResponse) -> Bool {
        lhs.transferUid == rhs.transferUid && lhs.success == rhs.success
    }
}
