import Foundation

public extension Endpoint {
    
    @available(*, renamed: "call()")
    func call(completion: @escaping (Result<Response, NetworkingError>) -> Void) {
        let task = URLSession(
            configuration: .ephemeral,
            delegate: self.delegate,
            delegateQueue: nil
        ).dataTask(with: request, completionHandler: sessionCompletionHandler(completion: completion))
        task.resume()
    }
    
    func upload(data: Data, completion: @escaping (Result<Response, NetworkingError>) -> Void) {
        let task = URLSession(
            configuration: .ephemeral,
            delegate: self.delegate,
            delegateQueue: nil
        ).uploadTask(with: request, from: data, completionHandler: sessionCompletionHandler(completion: completion))
        task.resume()
    }
    
    private func sessionCompletionHandler(
        completion: @escaping (Result<Response, NetworkingError>) -> Void
    ) -> (Data?, URLResponse?, Error?) -> Void {
        return { (data, response, error) in
            guard error == nil else {
                completion(.failure(NetworkingError.regular(error!, nil)))
                Logger.trace(level: .error, params: [String(describing: error)])
                return
            }
            do {
                Logger.log(loggingOptions: self.loggingOptions, level: .info, response: response, data: data!.valid)
                completion(.success(try self.decoder.decode(Response.self, from: data!.valid)))
            } catch let error {
                
                do {
                    // try to decode response in status error
                    let networkError = try self.decoder.decode(NetworkingError.self, from: data!.valid)
                    if case .status = networkError {
                        completion(.failure(networkError))
                    }
                    return
                } catch {
                    // DO NOTHING
                }
                completion(.failure( NetworkingError.regular(error, nil) ))
                Logger.traceDecodingError(error: error)
            }
            
        }
    }
    
    private func verify(data: Any?, urlResponse: HTTPURLResponse, error: Error?) -> Result<Any, NetworkingError> {
        let status = StatusCode(rawValue: urlResponse.statusCode)
        
        switch status {
        case .some(.unauthorized),
             .some(.logicException):
                return .failure(NetworkingError.regular(error, status))
        default:
            switch status?.category() {
            case .successful:
                guard let data = data else {
                    return .failure(NetworkingError.regular(error, .noContent))
                }
                return .success(data)
            default:
                return .failure(NetworkingError.regular(error, status))
            }
        }
    }
    
//    func call() async throws -> Response {
//        return try await withCheckedThrowingContinuation { continuation in
//            let task = URLSession(
//                configuration: .ephemeral,
//                delegate: self.delegate,
//                delegateQueue: nil
//            ).dataTask(with: request) { data, response, error in
//                guard error == nil else {
//                    continuation.resume(with: .failure(  NetworkingError.regular(error!) ))
//                    return
//                }
//                do {
//                    continuation.resume(with: .success(try self.decoder.decode(Response.self, from: data!.valid)))
//                } catch let error {
//                    continuation.resume(with: .failure( NetworkingError.regular(error) ))
//                }
//            }
//            task.resume()
//        }
//    }
}

private extension Data {
    var valid: Data {
        if isEmpty {
            return "{}".data(using: .utf8)!
        }
        return self
    }
}
