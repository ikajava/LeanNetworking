//
//  Logger.swift
//  
//
//  Created by Shalva Avanashvili on 31.07.2020.
//

import Foundation

public enum NetworkLogLevel: Int {
    case error
    case warning
    case info
    case none
}

private extension Optional where Wrapped == String {
    var wrappedValue: String {
        self ?? ""
    }
}

public struct LoggingOptions: OptionSet {
    public let rawValue: Int

    public static let headers      = LoggingOptions(rawValue: 1 << 0)
    public static let body         = LoggingOptions(rawValue: 1 << 1)
    public static let url          = LoggingOptions(rawValue: 1 << 2)
    public static let response     = LoggingOptions(rawValue: 1 << 3)
    public static let httpMethod   = LoggingOptions(rawValue: 1 << 4)

    public static let none: LoggingOptions = []
    public static let all: LoggingOptions = [.headers,
                                             .body,
                                             .url,
                                             .response,
                                             .httpMethod]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public class Logger {
    static var loggingLevel: NetworkLogLevel = .info
    
    static func log(loggingOptions: LoggingOptions,
                    level: NetworkLogLevel,
                    request: URLRequest) {
        
        let method = request.httpMethod.wrappedValue
        let url = request.url?.absoluteString
        let headers = request.allHTTPHeaderFields ?? [:]

        var params: [Any] = ["📤 Request"]
        
        if loggingOptions.contains(.httpMethod) {
            params.append("HTTPMethod   -> \(method)")
        }
        
        if loggingOptions.contains(.url) {
            params.append("URL          -> \(url.wrappedValue)")
        }
        
        if loggingOptions.contains(.headers) {
            params.append(
                "Headers      -> [\(headers.map { "\($0.key): \($0.value)" }.joined(separator: ",\n                "))]"
            )
        }
        
        trace(level: level, params: params)
    }
    
    static func log(loggingOptions: LoggingOptions,
                    level: NetworkLogLevel,
                    response: URLResponse?,
                    data: Data) {
        
        let url = response?.url?.absoluteString
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        var params: [Any] = ["📤 Response"]
        
        if loggingOptions.contains(.url) {
            params.append("URL          -> \(url.wrappedValue)")
        }
        
        if loggingOptions.contains(.response) {
            params.append("Response     -> \(json ?? [:])")
        }
        
        if case .none = loggingOptions {
            return
        }
        Logger.trace(level: .info, params: params)
    }
    
    static func trace(level: NetworkLogLevel, params: [Any]) {
        #if DEBUG
        if level.rawValue > loggingLevel.rawValue { return }
        
        let heading: String
        switch level {
            case .error:
                heading = "‼️ NETWORKING ERROR"
            case .warning:
                heading = "⁉️ NETWORKING WARNING"
            case .info:
                heading = "✅ NETWORKING INFO"
            default:
                heading = "✉️ NETWORKING MESSAGE"
        }
        
        print("\(heading)")
        for param in params {
            print("\(String(describing: param))")
        }
        print("⏰ - \(Date().timeIntervalSince1970)")
        print("\n")
        
        #endif
    }
    
    static func traceDecodingError(error: Error) {
        #if DEBUG
        var fullError = String(describing: error)
        let errorDebugDescriptionRegex = #"(?<=debugDescription: ).*$"#
        
        if let range = fullError.range(of: errorDebugDescriptionRegex, options: .regularExpression) {
            fullError = String(describing: fullError[range])
        }
        
        print("""
            ‼️ NETWORKING ERROR
            🎭 DECODING ERROR - \(fullError.replacingOccurrences(of: "\\", with: ""))
            ⏰ - \(Date().timeIntervalSince1970)
            
            """)
        #endif
    }
}

