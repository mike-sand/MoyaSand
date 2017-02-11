//
//  MoyaProvider+GenericRequest.swift
//  Pods
//
//  Created by Michael Sanderson on 2/11/17.
//
//

import Foundation
import Moya
import Result

public extension MoyaProvider {
    
    func request<T>(_ target: Target, parser: @escaping (Response) throws -> T, completion: @escaping (Result<T, MoyaError>) -> Void) -> Cancellable {
        
        return self.request(target, completion: { (result) in
            do {
                let response = try result.dematerialize()
                let value = try parser(response)
                completion(Result(value: value))
            } catch {
                let error = error as? MoyaError ?? MoyaError.underlying(error)
                completion(Result(error: error))
            }
        })
    }
}
