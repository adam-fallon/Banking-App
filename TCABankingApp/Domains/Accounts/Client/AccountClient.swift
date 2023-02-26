import Foundation
import ComposableArchitecture

struct AccountClient {
    @Dependency (\.appContext) static var appContext
    @Dependency (\.roundingService) static var roundingService
    
    /// Return the transaction list for a `accountUid`, between two dates
    var getTransactions: @Sendable (String, DateInterval, String) async throws -> Transaction
    var roundUp: @Sendable ([Amount]) throws -> Amount
}

extension AccountClient {
    static let live = Self(
        getTransactions: { accountUid, dateInterval, accessToken in
            guard let getTransactionsForAccountURL = try? appContext
                .apiConfiguration
                .getURL(.transactions(accountUid: accountUid,
                                      minTransactionTimestamp: dateInterval.start.ISO8601Format(),
                                      maxTransactionTimestamp: dateInterval.end.ISO8601Format()))
            else {
                throw AccountClientError.other
            }
            
            guard !accessToken.isEmpty else {
                throw AccountClientError.invalidAccount
            }
            
            var request = URLRequest(url: getTransactionsForAccountURL)
            request.addValue("Bearer \(accessToken)",
                             forHTTPHeaderField: "Authorization")
            request.addValue("application/json",
                             forHTTPHeaderField: "Content-Type")
            
            let (data, _) = try await appContext
                .httpClient
                .data(request)
            
            do {
                var feed = try appContext
                    .jsonCoders
                    .decoder(.plain)
                    .decode(Transaction.self,
                            from: data)
                feed.id = appContext
                    .uuidService
                    .uuid(UUIDService.defaultSeed)
                return feed
            } catch let error {                
                throw AccountClientError.other
            }
        }, roundUp: { amounts in
            return try roundingService.batchRoundUp(amounts)
        })
}

extension AccountClient: DependencyKey {
    static let liveValue = AccountClient.live
}

extension DependencyValues {
  var accountClient: AccountClient {
    get { self[AccountClient.self] }
    set { self[AccountClient.self] = newValue }
  }
}
