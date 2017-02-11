//
//  MoyaProvider+Sand.swift
//  Pods
//
//  Created by Michael Sanderson on 2/9/17.
//
//

import Foundation
import Moya
import Result

//extension MoyaProvider {
//    
//    /// Generic request-making method.
//    @discardableResult
//    open func request<T>(_ target: Target, parser: @escaping (Moya.Response) throws -> T, completion: @escaping (Result<T, MoyaError>) -> Void) -> Cancellable {
//        return request(target, queue: queue, progress: progress) { (result) in
//            do {
//                let response = try result.dematerialize()
//                let value = try parser(response)
//                completion(Result(value: value))
//            } catch let error as MoyaError {
//                completion(Result(error: error))
//            } catch {
//                completion(Result(error: MoyaError.underlying(error)))
//            }
//        }
//    }
//    
//}
