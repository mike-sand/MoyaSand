import Foundation
import Moya
import MoyaSand
import Result

// MARK: - Provider setup

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

let GitHubProvider = MoyaProvider<GitHub>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

// MARK: - Provider support

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public enum GitHub {
    case zen
    case userProfile(String)
    case userRepositories(String)
}

extension GitHub: TargetType {
    public var baseURL: URL { return URL(string: "https://api.github.com")! }
    public var path: String {
        switch self {
        case .zen:
            return "/zen"
        case .userProfile(let name):
            return "/users/\(name.urlEscaped)"
        case .userRepositories(let name):
            return "/users/\(name.urlEscaped)/repos"
        }
    }
    public var method: Moya.Method {
        return .get
    }
    public var parameters: [String: Any]? {
        switch self {
        case .userRepositories(_):
            return ["sort": "pushed"]
        default:
            return nil
        }
    }
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    public var task: Task {
        return .request
    }
    public var validate: Bool {
        switch self {
        case .zen:
            return true
        default:
            return false
        }
    }
    public var sampleData: Data {
        switch self {
        case .zen:
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .userProfile(let name):
            return "{\"login\": \"\(name)\", \"id\": 100}".data(using: String.Encoding.utf8)!
        case .userRepositories(_):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        }
    }
}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}


/**
 * Target Type With Parser
 *
 * This is the example of how to implement self-parsing targets. See TargetTypeWithParser.swift for a more detailed discussion.
 */

extension GitHub : TargetTypeWithParser {
    
    public var parser : (Moya.Response) throws -> Any {
        switch self {
        case.zen:
            return { try $0.mapString() } // A single expression in a closure will automatically return
        case .userRepositories(_):
            return Parser.toNSArray //A method can be passed as a closure, without (). More specific parsers should be named for their use, not the type.
        case .userProfile(_):
            return Parser.asserionFailureParser //We're not sure how to handle this yet, so we pass in this method.
        }
    }
}

/**
 * Only the MoyaProviderTyped can use the TargetTypeWithParser, to enforce the type system. This creates a single property that can be accessed on an MoyaProvider.
 */
public extension MoyaProvider where Target : TargetTypeWithParser {
    
    var typeNSArray : MoyaProviderTyped<NSArray, Target> {
        return MoyaProviderTyped.create(with: self)
    }
}


/**
 * This `Parsers` class is one way to keep track of parsing methods, share processing steps, apply logging/testing logic, etc.
 */
struct Parser {
    
    /**
     * process(_ response: Response) -> Response
     * 
     * This checks if a launch arguement was passed to print responses, if so it will print them to the console, returning the result so this method can be changed. 
     * Launch arguements appear in UserDefaults, see http://nshipster.com/launch-arguments-and-environment-variables/
     */
    @discardableResult
    static func process(_ response: Response) -> Response {
        if UserDefaults.standard.bool(forKey: "printResponseLaunchArguement") == true {
            debugPrint(response)
        }
        return response
    }
    
    // Parse response to single String
    static func toString(response: Response) throws -> String {
        return try process(response).mapString()
    }
    
    ///Parse response to an NSArray
    static func toNSArray(response: Response) throws -> NSArray {
        guard let json = try process(response).mapJSON() as? NSArray else {
            throw MoyaError.jsonMapping(response)
        }
        return json
    }
    
    /// It's unlikely we would call this method because it would require a MoyaProviderTyped, but it could be useful to stub out some data.
    static func asserionFailureParser(response: Response) throws -> Response {
        process(response)
        assertionFailure("No parser defined for response: \(response)")
        return response
    }
}

