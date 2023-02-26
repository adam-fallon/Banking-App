import Foundation
import ComposableArchitecture

struct UUIDService {
    var uuid: (String) -> (UUID)
    static let defaultSeed = "default"
}

extension UUIDService {
    static let live = UUIDService { seed in
        return UUID()
    }
}

extension UUIDService {
    static let test = UUIDService { seed in
        let seeds = [
            "default": TestHelpers.Transactions.defaultTransactionUid
        ]
        guard let match = seeds[seed],
              let uuid = UUID(uuidString: match) else {
            return UUID()
        }
        
        return uuid
    }
}

extension UUIDService: DependencyKey {
    static let liveValue = UUIDService.live
}

extension UUIDService: TestDependencyKey {
    static let testValue = UUIDService.test
}

extension DependencyValues {
  var uuidService: UUIDService {
    get { self[UUIDService.self] }
    set { self[UUIDService.self] = newValue }
  }
}

