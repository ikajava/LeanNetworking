import Foundation
import Combine

public extension Endpoint {
    
    func asFuture() -> Future<Response, NetworkingError> {
        Logger.log(loggingOptions: loggingOptions, level: .info, request: request)
        
        return Future<Response, NetworkingError> { [weak self] promise in
            guard let self = self else { return }
            let task = URLSession(
                configuration: .ephemeral,
                delegate: self.delegate,
                delegateQueue: nil
            ).dataTask(with: self.request) { data, response, error in
                guard let status = (response as? HTTPURLResponse)?.statusCode,
                      let statusCode = StatusCode(rawValue: status) else
                {
                    promise(.failure(.regular(nil, nil)))
                    Logger.trace(level: .error, params: ["No status code"])
                    return
                }
                
                if statusCode == .notFound {
                    promise(
                        .failure(
                            .regular(nil, statusCode)
                        )
                    )
                    Logger.trace(level: .error, params: ["\(statusCode.description()): \(statusCode.rawValue)"])
                    
                    return
                }
                
                guard error == nil else {
                    promise(.failure( NetworkingError.regular(error, statusCode) ))
                    Logger.trace(level: .error, params: [String(describing: error)])
                    return
                }
                
                do {
                    Logger.log(loggingOptions: self.loggingOptions, level: .info, response: response, data: data!.valid)
                    promise(.success(try self.decoder.decode(Response.self, from: data!.valid)))
                } catch let error {
                    
                    do {
                        // try to decode response in status error
                        let networkError = try self.decoder.decode(NetworkingError.self, from: data!.valid)
                        if case .status = networkError {
                            promise(.failure(networkError))
                        }
                        
                        return
                    } catch {
                        // DO NOTHING
                    }
                    
                    promise(.failure( NetworkingError.regular(error, statusCode) ))
                    Logger.traceDecodingError(error: error)
                }
            }
            task.resume()
        }
    }
    
    func call(completion: @escaping (Result<Response, NetworkingError>) -> Void) {
        let task = URLSession(
            configuration: .ephemeral,
            delegate: self.delegate,
            delegateQueue: nil
        ).dataTask(with: request) { data, response, error in
            guard let status = (response as? HTTPURLResponse)?.statusCode,
                  let statusCode = StatusCode(rawValue: status) else
            {
                completion(.failure( .regular(nil, nil) ))
                return
            }
            
            guard error == nil else {
                completion(.failure( .regular(error!, statusCode) ))
                return
            }
            do {
                completion(.success(try self.decoder.decode(Response.self, from: data!.valid)))
            } catch let error {
                completion(.failure( .regular(error, statusCode) ))
            }
        }
        task.resume()
    }
}

private extension Data {
    var valid: Data {
        if isEmpty {
            return "{}".data(using: .utf8)!
        }
        return self
    }
}
