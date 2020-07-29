//
//  Endpoint.swift
//  LeanNetworking
//
//  Created by Oleksandr Glagoliev on 10.07.2020.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

//MARK: - CLIENT -
public final class Endpoint<Response: Decodable> {
    private let baseURL: String
    
    private var url: URL!
    private var headers: [Pair] = []
    private var pathParams: [String] = []
    private var queryItems: [Pair] = []
    private var method: RequestMethod = .POST
    private var httpBody: Data? = nil
    
    private(set) var encoder = JSONEncoder()
    private(set) var decoder = JSONDecoder()
    private(set) var request: URLRequest!
    
    public init(baseURL: String) {
        self.baseURL = baseURL
        url = URL(string: baseURL)!
    }
    
    @discardableResult
    public func appendingPathParameter(_ value: String) -> Endpoint {
        url.appendPathComponent(value)
        return self
    }
    
    @discardableResult
    public func appendingQueryItem(key: String, value: String) -> Endpoint {
        queryItems.append(Pair(key: key, value: value))
        return self
    }
    
    @discardableResult
    public func appendingHeader(key: String, value: String) -> Endpoint {
        headers.append(Pair(key: key, value: value))
        return self
    }
    
    @discardableResult
    public func usingMethod(_ method: RequestMethod) -> Endpoint {
        self.method = method
        return self
    }
    
    @discardableResult
    public func usingUserAgent(_ userAgent: String) -> Endpoint {
        self.headers.append(Pair(key: "User-Agent", value: userAgent))
        return self
    }
    
    @discardableResult
    public func usingContentType(_ mimeType: String) -> Endpoint {
        self.headers.append(Pair(key: "Content-Type", value: mimeType))
        return self
    }
    
    @discardableResult
    public func signed(_ bearer: String) -> Endpoint {
        headers.append(Pair(key: "Authorization", value: bearer))
        return self
    }
    
    @discardableResult
    func bySettingBody<T: Encodable>(_ body: T) -> Endpoint {
        httpBody = try? encoder.encode(body)
        return self
    }
    
    @discardableResult
    public func usingDateDecodingStrategy(_ formatter: DateFormatter) -> Endpoint {
        decoder.dateDecodingStrategy = .formatted(formatter)
        return self
    }
    
    @discardableResult
    public func build() throws -> Endpoint {
        // Query items
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
                .map {
                    URLQueryItem(
                        name: $0.key,
                        value: $0.value
                    )
            }
        }
        
        // URLRequest setup
        request = URLRequest(url: components!.url!)
        request.httpMethod = method.rawValue
        headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        request.httpBody = httpBody
        
        return self
    }
}
