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

In order to use LeanNetworking developer should do according to these steps:

First create a function with return type of result model and error
```
    func example(completion: @escaping (Result<ExampleStruct, Error>) -> Void) {
    ...
    }
```  
Second creating an instance of Endpoint by determining Result model and also Webservice Url

```
    func example(completion: @escaping (Result<ExampleStruct, Error>) -> Void) {
        Endpoint<ExampleStructDTO>(baseURL: webserviceURL)
        ...
    }
```
Third defining type of request method. For example here we used ".get".Then developer can assign parameters in form of aray and also bearertoken.
```
    func example(completion: @escaping (Result<ExampleStruct, Error>) -> Void) {
        Endpoint<ExampleStructDTO>(baseURL: webserviceURL)
            .get("exampleURL", parameters: [], token: bearerToken)
            ...
    }
```
Then we add .asFuture() in order to being notified when the publisher emits an element or terminates with an error.

```
        ...
            .get("exampleURL", parameters: [], token: bearerToken)
            .asFuture()
        ...
    }
```
In order to creates the subscriber and immediately requests an unlimited number of values we use ".sink" Sink has two parameter and one return type.
First parameter is "receiveComplete" which is a closure that will be execute on completion.
Second parameter is "receiveValue" which is a closure that will be executed on receipt of a value.

```    ...
            .asFuture()
            .sink { receiveComplete in
                if case let .failure(networkingError) = receiveComplete {
                    completion(.failure(networkingError))
                }
            } receiveValue: { response in
                completion(.success(response))
            }
        ...
    }
```

Finally the return value should be held, otherwise the stream will be canceled so we will store it using ".store(in: ... )"

```
        ...
            .sink { receiveComplete in
                if case let .failure(networkingError) = receiveComplete {
                    completion(.failure(networkingError))
                }
            } receiveValue: { response in
                completion(.success(response))
            }
            .store(in: &cancellables)
    }
```
