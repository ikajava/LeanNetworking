# LeanNetworking

## The goal

LeanNetworking (LN) is a thin wrapper on URLSession APIs that is built to provide ergonomic Networking functionality for iOS Applications.

## Features
- Ergonomic
- `Combine` compatible
- Declarative syntax
- Light and fast
- Decoding/Encoding with `Codable` 
- Multilevel logging

## The goal

The goal of the package is to provide clear, concise and ergonomic API for work with server side services.

## Usage

Add LeanNetworking SPM package:
```
dependencies: [
    .package(name: "LeanNetworking", url: "git@bitbucket.org:onofftelecom/albums-ios-lean-networking.git", .branch("master"))
]
```

Import where appropriate:
```
import LeanNetworking
```

### POST request

Let's say you need to send JSON encodable `SomeStruct` in a `POST` request and receive JSON that decodes into `SomeResponse` struct.

You can use either Promise or a Callback to receive values:

```
let payload = SomeStruct(
    field1: "field_1_value",
    field2: 2
)

// In case you want to use promises        
Endpoint<SomeResponse>(baseURL: "YOUR_URL")
            .post("the/part/of/the/url", body: payload, token: "YOUR_AUTH_BEARER_IF_NEEDED")
            .asFuture()
            
// In case you want to use Callback        
Endpoint<SomeResponse>(baseURL: "YOUR_URL")
            .post("the/part/of/the/url", body: payload, token: "YOUR_AUTH_BEARER_IF_NEEDED")
            .call { someResponse in /* Your callback implementation */ }

```  

### GET, POST, PUT...

Performed in similar fashion as `POST` requests with the exception that parameters are handled in a way as follows:

```
Endpoint<SomeRespoinse>(baseURL: "YOUR_URL")
            .get(
                "some/url/part",
                optionalParameters: [
                    Endpoint.OptionalPair(key: "someParam", value: "someVal"),
                    Endpoint.OptionalPair(key: "limit", value: 0),
                    Endpoint.OptionalPair(key: "offset", value: 10)
                ],
                token: "YOUR_AUTH_BEARER_IF_NEEDED"
            )
            .asFuture()
```
