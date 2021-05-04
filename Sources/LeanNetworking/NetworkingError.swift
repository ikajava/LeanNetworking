import Foundation

public enum NetworkingError: Error, Codable {
    case status(String)
    case regular(Error)
}

extension NetworkingError {

    private enum CodingKeys: String, CodingKey {
        case status
    }

    enum NetworkingErrorCodingError: Error {
        case decoding(String)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .status) {
            self = .status(value)
            return
        }
        
        throw NetworkingErrorCodingError.decoding("Decoding Error!: \(dump(values))")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .status(errorStatus):
            try container.encode(errorStatus, forKey: .status)
        default: break
        }
    }
}
