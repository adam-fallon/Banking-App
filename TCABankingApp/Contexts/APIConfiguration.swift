import Foundation
import ComposableArchitecture

enum Endpoint: Hashable {
    case user
    case savings(accountUid: String, savingsGoalUid: String, transactionUid: String)
    case goals(accountUid: String)
    case transactions(accountUid: String, minTransactionTimestamp: String, maxTransactionTimestamp: String)
}

protocol API {
    static var baseURL: URL { get }
}

private enum APIEndpoint {
    enum User: String, API {
        private static var version: String { "v2" }
        static var baseURL: URL = URL(string: "https://api-sandbox.starlingbank.com/api/\(User.version)")!
        case accounts = "accounts"
    }
    
    enum Savings: String, API {
        private static var version: String { "v2" }
        /// /api/v2/account/{accountUid}/savings-goals
        static var baseURL: URL = URL(string: "https://api-sandbox.starlingbank.com/api/\(Savings.version)")!
        case savings_goals = "savings-goals"
        case account = "account"
        case add_money = "add-money"        
        
        enum SavingsEndpointError: Error {
            case failedToConstructAccountURL
        }
    }
    
    enum Transactions: String, API {
        private static var version: String { "v2" }
        static var baseURL: URL = URL(string: "https://api-sandbox.starlingbank.com/api/\(Transactions.version)")!
        case feed = "feed"
        case account = "account"
        case between = "settled-transactions-between"
        
        enum Params: String {
            case minTransactionTimestamp
            case maxTransactionTimestamp
        }
        
        
        enum SavingsEndpointError: Error {
            case failedToConstructAccountURL
        }
    }
}

private extension RawRepresentable where RawValue == String, Self: API {
    var url: URL { Self.baseURL.appendingPathComponent(rawValue) }
}

struct APIConfiguration {
    var getURL: (Endpoint) throws -> URL
}

extension APIConfiguration {
    static let live = Self(
        getURL: { endpoint in
            switch endpoint {
            case .user:
                return APIEndpoint.User.accounts.url
            case .transactions(let accountUid, let minTransactionTimestamp, let maxTransactionTimestamp):
                var transactionUrl = APIEndpoint.Transactions.baseURL
                    .appendingPathComponent(APIEndpoint.Transactions.feed.rawValue)
                    .appendingPathComponent(APIEndpoint.Transactions.account.rawValue)
                    .appendingPathComponent(accountUid)
                    .appendingPathComponent(APIEndpoint.Transactions.between.rawValue)
                
                transactionUrl.appendQueryItem(name: APIEndpoint.Transactions.Params.minTransactionTimestamp.rawValue,
                                               value: minTransactionTimestamp)
                transactionUrl.appendQueryItem(name: APIEndpoint.Transactions.Params.maxTransactionTimestamp.rawValue,
                                               value: maxTransactionTimestamp)
                
                return transactionUrl
            case .savings(let accountUid, let savingsUid, let transactionUid):
                return APIEndpoint.Savings.baseURL
                    .appendingPathComponent(APIEndpoint.Savings.account.rawValue)
                    .appendingPathComponent(accountUid)
                    .appendingPathComponent(APIEndpoint.Savings.savings_goals.rawValue)
                    .appendingPathComponent(savingsUid)
                    .appendingPathComponent(APIEndpoint.Savings.add_money.rawValue)
                    .appendingPathComponent(transactionUid)
            case .goals(let accountUid):
                return APIEndpoint.Savings.baseURL
                    .appendingPathComponent(APIEndpoint.Savings.account.rawValue)
                    .appendingPathComponent(accountUid)
                    .appendingPathComponent(APIEndpoint.Savings.savings_goals.rawValue)
            }
        }
    )
}

extension APIConfiguration {
    static let unimplemented = Self(
        getURL: { _ in fatalError("Looks like you are trying to use a real API call from a test. Don't do that!") }
    )
}

extension APIConfiguration: DependencyKey {
    static let liveValue = APIConfiguration.live
}

extension DependencyValues {
    var apiConfiguration: APIConfiguration {
        get { self[APIConfiguration.self] }
        set { self[APIConfiguration.self] = newValue }
    }
}

extension URL {

    mutating func appendQueryItem(name: String, value: String?) {

        guard var urlComponents = URLComponents(string: absoluteString) else { return }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: name, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        self = urlComponents.url!
    }
}
