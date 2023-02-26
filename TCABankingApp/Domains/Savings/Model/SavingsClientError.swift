import Foundation

enum SavingsClientError: Error {
    case invalidAccount
    case other
}

extension SavingsClientError: Equatable {
    static func == (lhs: SavingsClientError, rhs: SavingsClientError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}

extension SavingsClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAccount:
            return "Something went wrong with your account. You will now be logged out"
        default:
            return "Oops, something went wrong. Please try again."
        }
    }
}

