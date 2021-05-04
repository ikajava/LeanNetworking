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
            .asFuture()
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { val in
                print(val)
            }).store(in: &cancellables)
    }
```

### .asFuture() :

where the Future is defined as Future<Output, Failure> where the Output is of generic type and Failure is Error type.

### .sink : 

consists of three parts:

parameter receiveComplete: The closure to execute on completion.

parameter receiveValue: The closure to execute on receipt of a value.

Returns: A cancellable instance, which you use when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.

### .store :

Stores type-erasing cancellable instance in the specified set.


```
    func storageStatistics(completion: @escaping (Result<StorageStatistics, NetworkingError>) -> Void) {
        Endpoint<StorageStatisticsDTO>(baseURL: ApplicationConfig.webserviceURL)
            .get("storage/statistics", parameters: [], token: API.shared.authorisationBearer)
            .asFuture()
            .sink { result in
                if case let .failure(networkingError) = result {
                    completion(.failure(networkingError))
                }
            } receiveValue: { response in
                completion(.success(response.toStorageStatistics()))
            }
            .store(in: &cancellables)
    }
```