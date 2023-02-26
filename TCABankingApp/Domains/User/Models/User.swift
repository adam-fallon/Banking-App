import Foundation

// MARK: - User
struct User: Codable, Equatable {
    let accounts: [Account]
    var accessToken: String?
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.accessToken == rhs.accessToken
    }
}
