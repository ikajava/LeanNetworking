# LeanNetworking

LeanNetworking is a Swift network library provides convenience in working with server side services.

## The goal

The goal of the package is to provide clear, concise and ergonomic API for work with server side services.

## Usage

Add LeanNetworking package:
```
dependencies: [
    .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.0.0")
    ]
```
Import where appropriate:
```
import LeanNetworking
```
In order to use LeanNetworking developer should use it like below example:

```
    func example(completion: @escaping (Result<ExampleStruct, Error>) -> Void) {
        Endpoint<ResultExampleStruct>(baseURL: ApplicationConfig.webserviceURL)
            .get("storage/statistics", parameters: [], token: API.shared.authorisationBearer)
            .asFuture()
            .sink { result in
                if case let .failure(networkingError) = result {
                    completion(.failure(networkingError))
                }
            } receiveValue: { response in
                completion(.success(response))
            }
            .store(in: &cancellables)
    }
```