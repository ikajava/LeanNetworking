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
        return {(data, response, error) in
            
            guard let response = response as? HTTPURLResponse else { return }
            Logger.log(loggingOptions: self.loggingOptions, level: .info, request: self.request)
            
            let result = self.verify(data: data, urlResponse: response, error: error)
            
            switch result {
            case .success(let data):
                Logger.log(loggingOptions: self.loggingOptions, level: .info, response: response, data: data.valid)
                self.decodeData(data: data, completion: completion)
            case .failure(let error):
                completion(.failure(error))
                Logger.trace(level: .error, params: [error])
            }
        }
    }
    
    private func verify(data: Data?, urlResponse: HTTPURLResponse, error: Error?) -> Result<Data, NetworkingError> {
        guard let status = StatusCode(rawValue: urlResponse.statusCode) else {
            return .failure(NetworkingError.regular(error, nil))
        }
        
        switch status {
        case .logicException: // FOR 209
                return .failure(NetworkingError.regular(error, status))
        default:
            switch status.category() {
            case .successful:
                guard let data = data else {
                    let error = NetworkingError.regular(error, .noContent)
                    return .failure(error)
                }
                return .success(data)
            default:
                
                return .failure(NetworkingError.regular(error, status))
            }
        }
    }
    
    private func decodeData(data: Data, completion: @escaping (Result<Response, NetworkingError>) -> Void) {
        do {
            let response = try decoder.decode(Response.self, from: data)
            completion(.success(response))
        } catch let error {
            do {
                let networkError = try self.decoder.decode(NetworkingError.self, from: data.valid)
                completion(.failure(networkError))
            } catch _ {
                // Do nothing
            }
            completion(.failure( NetworkingError.regular(error, nil) ))
        }
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
