# MoyaSand

MoyaSand is an extension to the [Moya](https://github.com/moya/moya) network abstraction layer written in Swift. The extension allows for fully encapsulated handling of the network layer.  

Note: MoyaSand does *not* provide a method of JSON parsing. The goal of MoyaSand is to encapsulate the parsing by moving it away from the call site. The extension is not for use with ReactiveSwift and RxCocoa at this time.

Two techniques are included:

* `TargetTypeWithParser` is a protocol that targets adopt and a wrapper for MoyaProvider. It lets targets specify the parsing method. 
* `MoyaProvider+GenericRequest` moves the paring logic to a closure parameter but still requires the call site to specify what parsing to use. 

## TargetTypeWithParser

`TargetTypeWithParser` is a protocol with a single property requirement 

```swift
var parser : (Response) throws -> Any { get }
```

The return is a function that takes a `Response` and returns a type or throws an error. 

The function returns `Any` to cross the Swift strongly-typed barrier, but the parser can and should return the concrete type it expects. 

### Methods as Closures  

The function can be created with closure syntax but can be a function in another class or struct. To pass a function with the signature `(Response) throws -> [Type]` simply pass the class and function without the `()` that would invoke it:

```swift
extension SomeTarget : TargetTypeWithParser {
    var parser : (Response) throws -> Any {
        return Parser.singleString
    }
}

struct Parser {
    func singleString(response: Response) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw MoyaError.stringMapping(response)
        }
        return string
    }
}
```

### MoyaProviderTyped

To preserve type safety the `MoyaProvider` must be wrapped. This is done by creating a `MoyaProviderTyped` for each type that can be returned. This can be done in an extension that creates the wrapper as needed with a one-line function for each type: 

```swift 
extension MoyaProvider where Target : TargetTypeWithParser {
    var typeNSArray : MoyaProviderTyped<NSArray, Target> {
        return MoyaProviderTyped.create(with: self)
    }

    var typeModel : MoyaProviderTyped<Model, Target> {
        return MoyaProviderTyped.create(with: self)
    }
}
```

Then to invoke the whole thing on your provider: 

```swift 
    
    GitHubProvider.typeNSArray.request(.aTarget) { (result) in 
        switch result {
            case let .Success(array):
                //do something with array 
            case let .Failure(error):
                //do something with error 
        }
    }
```

If the provider type does not match the type returned as `Any` from the parser, a jsonParsing error will be thrown.   

## MoyaProvider+GenericRequest 

Eliminates response handling from completion blocks by passing a parser closure. 

This extension adds a generic method to MoyaProvider that takes a parser that converts a `Response` to `T` and then passes that `T` to a completion block as a Result.  

`request<T>(_ target: Target, parser: (Response) throws -> T, completion: (Result<T, MoyaError>) -> Void) -> Cancellable` 

This requires the call site to pass the correct parser.  
    
```swift 
    request(.aTarget, parser: Parser.singleString) { (result) in
        swich result {
        case let .success(string):
            //do something with string
        case let .Failure(error):
            //error including parsing. 
        }
    }
```

This can also be written with the parsing logic defined in a closure: 

```swift 
    request(aTarget, parser: { (response) in 
        //handle parsing here, throw if error 
    } completion { (result) in 
        //do something with result
    }
```

These are addative to Moya and should not conflict with any existing uses. 

Your milage may vary if the increased encapsulation is worth it. 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The example usage is for `TargetTypeWithParser`. It is based on the Moya demo project. The conformance to `TargetTypeWithParser` is included in `GitHubAPI.swift` and includs creation of a `MoyaProviderTyped` for `NSArray`. The usage can be seen in `ViewController`.   

## Requirements

MoyaSand uses Swift 3.0. 

## Installation

MoyaSand is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MoyaSand"
```

## Author

mike-sand, git@mikesand.com

## License

MoyaSand is available under the MIT license. See the LICENSE file for more info.
