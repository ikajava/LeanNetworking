# LeanNetworking

A description of this package.


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
