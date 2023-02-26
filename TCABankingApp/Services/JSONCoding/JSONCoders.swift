import Foundation
import ComposableArchitecture

enum DecoderType {
    case plain
    case iso8601
}

enum EncoderType {
    case plain
}

enum DecoderError: Error {
    case noDecoderInCache
}

enum EncoderError: Error {
    case noEncoderInCache
}

struct JSONCoders {
    private static var decoderCache: [DecoderType: JSONDecoder] = [.iso8601: iso8601JsonDecoder, .plain: plainDecoder]
    private static var encoderCache: [EncoderType: JSONEncoder] = [.plain: plainEncoder]
    var decoder: (DecoderType) throws -> JSONDecoder
    var encoder: (EncoderType) throws -> JSONEncoder
}

// MARK: DECODERS
extension JSONCoders {
    
    private static let iso8601JsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    private static let plainDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
}

// MARK: ENCODERS
extension JSONCoders {
    private static let plainEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()
}

extension JSONCoders {
    static let live = Self(
        decoder: { type in
            switch type {
            case .plain:
                guard let decoder = decoderCache[.plain] else {
                    throw DecoderError.noDecoderInCache
                }
                
                return decoder
            case .iso8601:
                guard let decoder = decoderCache[.iso8601] else {
                    throw DecoderError.noDecoderInCache
                }
                
                return decoder
            }
        }, encoder: { type in
            switch type {
            case .plain:
                guard let encoder = encoderCache[.plain] else {
                    throw EncoderError.noEncoderInCache
                }
                
                return encoder
            }
    })
}

extension JSONCoders: TestDependencyKey {
    static let testValue = JSONCoders.live
}

extension JSONCoders: DependencyKey {
    static let liveValue = JSONCoders.live
}

extension DependencyValues {
  var jsonCoders: JSONCoders {
    get { self[JSONCoders.self] }
    set { self[JSONCoders.self] = newValue }
  }
}
