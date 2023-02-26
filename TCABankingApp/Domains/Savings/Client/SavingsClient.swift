import Foundation
import ComposableArchitecture

struct SavingsClient {
    @Dependency (\.appContext) static var appContext
    
    /// Saves a round up amount to a savings goal
    var saveRoundUp: @Sendable (String, String, Amount, String) async throws -> SavingsResponse
    
    ///  Get saving goals up for an account
    var getSavingGoals: @Sendable (String, String) async throws -> SavingGoalResponse
}


extension SavingsClient {
    static let live = Self(
        saveRoundUp: { accountUid, savingsGoalUid, amount, accessToken in
            let transactionUuid = appContext.uuidService.uuid(UUIDService.defaultSeed).uuidString
            guard let getTransactionsForAccountURL = try? appContext
                .apiConfiguration
                .getURL(.savings(accountUid: accountUid,
                                 savingsGoalUid: savingsGoalUid,
                                 transactionUid: transactionUuid))
            else {
                throw SavingsClientError.other
            }
            
            guard !accessToken.isEmpty else {
                throw SavingsClientError.invalidAccount
            }
            
            var request = URLRequest(url: getTransactionsForAccountURL)
            request.addValue("Bearer \(accessToken)",
                             forHTTPHeaderField: "Authorization")
            request.addValue("application/json",
                             forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            
            guard let postBody = try? appContext
                .jsonCoders
                .encoder(.plain)
                .encode(SavingsRequest(amount: amount))
            else {
                throw SavingsClientError.other
            }
            
            request.httpBody = postBody
            
            let (data, _) = try await appContext
                .httpClient
                .data(request)
            
            do {
                var response = try appContext
                    .jsonCoders
                    .decoder(.plain)
                    .decode(SavingsResponse.self,
                            from: data)
                return response
            } catch let error {
                throw SavingsClientError.other
            }
        },
        getSavingGoals: { accountUid, accessToken in
            guard let getTransactionsForAccountURL = try? appContext
                .apiConfiguration
                .getURL(.goals(accountUid: accountUid))
            else {
                throw SavingsClientError.other
            }
            
            guard !accessToken.isEmpty else {
                throw SavingsClientError.invalidAccount
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
                var response = try appContext
                    .jsonCoders
                    .decoder(.plain)
                    .decode(SavingGoalResponse.self,
                            from: data)
                return response
            } catch let error {
                throw SavingsClientError.other
            }
        }
    )
}

extension SavingsClient: DependencyKey {
    static let liveValue = SavingsClient.live
}

extension DependencyValues {
  var savingsClient: SavingsClient {
    get { self[SavingsClient.self] }
    set { self[SavingsClient.self] = newValue }
  }
}
