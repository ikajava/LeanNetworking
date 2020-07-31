//
//  Endpoint+Extensions.swift
//  LeanNetworking
//
//  Created by Oleksandr Glagoliev on 13.07.2020.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import Foundation
import Combine


func authoriseUser() -> AnyPublisher<Bool, Never> {
    // REFRESH TOKEN
    #warning("Incorrect implementation")
    return Just(false)
        .eraseToAnyPublisher()
}


public extension Endpoint {
    func asPublisher() -> AnyPublisher<Response, Error> {
        URLSession
            .shared
            .dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                    else {
                        throw try self.decoder.decode(APIError.self, from: result.data)
                }
                
                Logger.log(loggingOptions: self.loggingOptions,
                           level: .info,
                           response: result.response,
                           data: result.data)
                
                return try self.decoder.decode(Response.self, from: result.data)
        }
        .tryCatch({ error -> AnyPublisher<Response, Error> in
            guard
                let apiError = error as? APIError,
                apiError.statusCode == 401
                else {
                    Logger.trace(level: .error, params: [String(describing: error)])
                    throw error
            }
            return authoriseUser()
                .tryMap { [weak self] success -> AnyPublisher<Response, Error> in
                    guard let self = self else {
                        Logger.trace(level: .error, params: [String(describing: error)])
                        throw error
                    }
                    guard success else {
                        Logger.trace(level: .error, params: [String(describing: error)])
                        throw error
                    }
                    return self.asPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
            }
        ).eraseToAnyPublisher()
    }
    
    func asFuture() -> Future<Response, Error> {
        Logger.log(loggingOptions: loggingOptions, level: .info, request: request)
        
        return Future<Response, Error> { promise in
            let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
                guard error == nil else {
                    promise(.failure(error!))
                    Logger.trace(level: .error, params: [String(describing: error)])
                    return
                }
                do {
                    Logger.log(loggingOptions: self.loggingOptions, level: .info, response: response, data: data!)
                    promise(.success(try self.decoder.decode(Response.self, from: data!)))
                } catch let error {
                    promise(.failure(error))
                    Logger.traceDecodingError(error: error)
                }
            }
            task.resume()
        }
    }
    
    func call(completion: @escaping (Result<Response, Error>) -> Void) {
        let task = URLSession
            .shared
            .dataTask(with: request) { data, response, error in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                do {
                    completion(.success(try self.decoder.decode(Response.self, from: data!)))
                } catch let error {
                    completion(.failure(error))
                }
        }
        task.resume()
    }
    
}
