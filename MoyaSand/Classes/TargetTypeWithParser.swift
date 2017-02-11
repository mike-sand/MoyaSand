//
//  TargetTypeWithParser.swift
//  Pods
//
//  Created by Michael Sanderson on 2/11/17.
//
//

import Foundation
import Moya
import Result

/**
 * Target Type With Parser
 *
 * This will allow MoyaProvider to parse a Target, removing all response handling from the call site.
 *
 * * 1. Conform Target to `TargetTypeWithParser`. This is a single (probably computed) property:
 *
 *   `var parser : (Moya.Response) throws -> Any { get } `
 *
 *   This returns a function that transforms a `Moya.Response` to `Any`
 *
 *   Note: `Any` in the function signature is just cross the strongly-typed barrier, you should return the concrete type expected or throw an error
 *
 * * 2. Create MoyaProviderTyped for each custom type.
 *
 *   Create a MoyaProviderTyped for each type the target can return. A Typed provider for String is included.
 *
 *   Note: Because of generic initalizer issues, use the static method `MoyaProviderTyped.create(with: self)`
 *
 *   Intended usage:
 *
 *   The intended way to do this is shown, to create extensions on MoyaProvider with the decleration `extension MoyaProvider where Target : TargetTypeWithParser`.
 *
 *   Add a computed property for each type:
 *   var typeString : MoyaProviderTyped<String, Target> {
 *       return MoyaProviderTyped.create(with: self)
 *   }
 *
 *   Then any MoyaProvider where Target: TargetTypeWithParser can access the automatically parsed method with `ConcreteMoyaProvider.typeString.request...`
 *
 *   The response will be parsed and cast to the MoyaProvider type, then returned to the call site as a Result with the value or any error that happend.
 */

/**
 * Protocol a TargetType conforms to
 */
public protocol TargetTypeWithParser : TargetType {
    var parser : (Moya.Response) throws -> Any { get }
}

/**
 * MoyaProviderTyped. Create a property for each return type.
 */
public extension MoyaProvider where Target : TargetTypeWithParser {
    
    var typeString : MoyaProviderTyped<String, Target> {
        return MoyaProviderTyped.create(with: self)
    }
}

public struct MoyaProviderTyped<ResultType, Target: TargetTypeWithParser> {
    
    private let provider : MoyaProvider<Target>
    
    ///Create a MoyaProviderTyped. Use this to avoid issues initalizing a generic across framework boundries.
    public static func create(with provider: MoyaProvider<Target>) ->  MoyaProviderTyped  {
        return MoyaProviderTyped(provider: provider)
    }
    
    /// Designated request-making method for TargetTypeWithParser. Returns a `Cancellable` token to cancel the request later.
    @discardableResult
    public func request(_ target: Target, queue: DispatchQueue? = nil, progress: Moya.ProgressBlock? = nil, completion: @escaping (Result<ResultType, MoyaError>) -> Void) -> Cancellable {
        
        return provider.request(target, queue: queue, progress: progress, completion: { (result) in
            do {
                let response = try result.dematerialize()
                let any = try target.parser(response)
                guard let value = any as? ResultType else {
                    throw MoyaError.jsonMapping(response)
                }
                completion(Result(value: value))
            } catch {
                let error = error as? MoyaError ?? MoyaError.underlying(error)
                completion(Result(error: error))
            }
        })
    }
}




