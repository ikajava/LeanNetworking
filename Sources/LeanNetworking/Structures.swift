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

public enum StatusCode: Int {
    case `continue` = 100
    case switchingProtocols = 101
    case OK = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case logicException = 209
    case multiplechoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case temporaryRedirect = 307
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case requestEntityTooLarge = 413
    case requestURITooLong = 414
    case unsupportedMediaType = 415
    case requestedRangeNotSatisfiable = 416
    case expectationFailed = 417
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case HTTPVersionNotSupported = 505
    
    public func category() -> StatusCodeCategory {
        if (100...199).contains(self.rawValue) { return .informational }
        if (200...299).contains(self.rawValue) { return .successful }
        if (300...399).contains(self.rawValue) { return .redirection }
        if (400...499).contains(self.rawValue) { return .clientError }
        if (599...599).contains(self.rawValue) { return .serverError }
        
        return .serverError
    }
    
    func description() -> String {
        switch self {
            case .`continue`: return "Continue"
            case .switchingProtocols: return "Switching Protocols"
            case .OK: return "OK"
            case .created: return "Created"
            case .accepted: return "Accepted"
            case .nonAuthoritativeInformation: return "Non-Authoritative Information"
            case .noContent: return "No Content"
            case .resetContent: return "Reset Content"
            case .partialContent: return "Partial Content"
            case .logicException: return "Logic Exception"
            case .multiplechoices: return "Multiple Choices"
            case .movedPermanently: return "Moved Permanently"
            case .found: return "Found"
            case .seeOther: return "See Other"
            case .notModified: return "Not Modified"
            case .useProxy: return "Use Proxy"
            case .temporaryRedirect: return "Temporary Redirect"
            case .badRequest: return "Bad Request"
            case .unauthorized: return "Unauthorized"
            case .paymentRequired: return "Payment Required"
            case .forbidden: return "Forbidden"
            case .notFound: return "Not Found"
            case .methodNotAllowed: return "Method Not Allowed"
            case .notAcceptable: return "Not Acceptable"
            case .proxyAuthenticationRequired: return "Proxy Authentication Required"
            case .requestTimeout: return "Request Timeout"
            case .conflict: return "Conflict"
            case .gone: return "Gone"
            case .lengthRequired: return "Length Required"
            case .preconditionFailed: return "Precondition Failed"
            case .requestEntityTooLarge: return "Request Entity Too Large"
            case .requestURITooLong: return "Request-URI Too Long"
            case .unsupportedMediaType: return "Unsupported Media Type"
            case .requestedRangeNotSatisfiable: return "Requested Range Not Satisfiable"
            case .expectationFailed: return "Expectation Failed"
            case .internalServerError: return "Internal Server Error"
            case .notImplemented: return "Not Implemented"
            case .badGateway: return "Bad Gateway"
            case .serviceUnavailable: return "Service Unavailable"
            case .gatewayTimeout: return "Gateway Timeout"
            case .HTTPVersionNotSupported: return "HTTP Version Not Supported"
        }
    }
}

public enum StatusCodeCategory {
    case informational
    case successful
    case redirection
    case clientError
    case serverError
}
