import Foundation

enum AccountClientError: Error {
    case invalidAccount
    case other
}

extension AccountClientError: Equatable {
    static func == (lhs: AccountClientError, rhs: AccountClientError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}

extension AccountClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAccount:
            return "Login failed."
        default:
            return "Oops, something went wrong. Please try again."
        }
    }
}
