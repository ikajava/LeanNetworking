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


//            .asPublisher()
//            .sink(receiveCompletion: { completion in
//                print(completion)
//            }, receiveValue: { val in
//                print(val)
//            }).store(in: &cancellables)
                
            .asFuture()
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { val in
                print(val)
            }).store(in: &cancellables)
    }
