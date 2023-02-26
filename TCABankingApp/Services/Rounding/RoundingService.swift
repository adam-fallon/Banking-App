import Foundation
import ComposableArchitecture

/// A service to round up currencies of the same type
struct RoundingService {
    var batchRoundUp: (_ amounts: [Amount]) throws -> Amount
}

extension RoundingService {
    /// Return addititon of rounding up `moneys` to nearest whole.
    static let live = RoundingService { amounts in
        if amounts.count >= 100 { throw RoundingError.amountSizeTooBig }
        
        let currencySet = Set(amounts.map { $0.currency })
        
        guard currencySet.count == 1, let currency = currencySet.first else {
            throw RoundingError.mismatchedCurrency
        }

        let roundUp = amounts
            .filter { $0.toDecimal.isNormal && $0.toDecimal.sign == .plus }
            .map { amount in
                var decimal = amount.toDecimal
                var rounded = Decimal()
                NSDecimalRound(&rounded, &decimal, 0, .up)
                
                return rounded - amount.toDecimal
            }
            .reduce(0) {
                $0 + $1
            }

        // Technically this wouldn't work for non-denary currency like Japanese yen,
        // but thats not the problem space I am in for this test, and the API didn't give me a fractional value for currency.
        return Amount(currency: currency, minorUnits: (roundUp * 100 as NSDecimalNumber).intValue)
    }
}

enum RoundingError: Error, Equatable {
    case mismatchedCurrency
    case amountSizeTooBig
    case emptyOrNilTransaction
}

extension RoundingService: DependencyKey {
    static let liveValue = RoundingService.live
}

extension RoundingService: TestDependencyKey {
    static let testValue = RoundingService.live
}

extension DependencyValues {
  var roundingService: RoundingService {
    get { self[RoundingService.self] }
    set { self[RoundingService.self] = newValue }
  }
}
