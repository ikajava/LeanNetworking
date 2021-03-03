
import Foundation
import Combine

public extension Endpoint {
    
    func asFuture() -> Future<Response, NetworkingError> {
        Logger.log(loggingOptions: loggingOptions, level: .info, request: request)
        
        return Future<Response, NetworkingError> { promise in
            let task = URLSession(
                configuration: .ephemeral,
                delegate: Pin(),
                delegateQueue: nil
            ).dataTask(with: self.request) { data, response, error in
                
                guard error == nil else {
                    promise(.failure( NetworkingError.regular(error!) ))
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
                    
                    promise(.failure( NetworkingError.regular(error) ))
                    Logger.traceDecodingError(error: error)
                }
            }
            task.resume()
        }
    }
    
    func call(completion: @escaping (Result<Response, NetworkingError>) -> Void) {
        let task = URLSession(
            configuration: .ephemeral,
            delegate: Pin(),
            delegateQueue: nil
        ).dataTask(with: request) { data, response, error in
            
                guard error == nil else {
                    completion(.failure(  NetworkingError.regular(error!) ))
                    return
                }
                do {
                    completion(.success(try self.decoder.decode(Response.self, from: data!.valid)))
                } catch let error {
                    completion(.failure( NetworkingError.regular(error) ))
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
