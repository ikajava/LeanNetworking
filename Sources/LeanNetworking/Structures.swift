import Foundation

// MARK: - Key-Value -
struct Pair {
    let key: String
    let value: String
}

// MARK: - Method
public enum RequestMethod: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}

// MARK: - Body
struct APIError: Decodable, Error {
    let statusCode: Int
}
