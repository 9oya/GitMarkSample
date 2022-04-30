//
//  APIRouter.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import Alamofire

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "accept"
    case acceptEncoding = "Accept-Encoding"
    case userAgent = "User-Agent"
    case appToken = "App-Token"
}

enum AcceptType: String {
    case anyMIMEgtype = "*/*"
    case githubV3Json = "application/vnd.github.v3+json"
}

enum UserSortType: String {
    case repos = "repositories"
    case followers = "followers"
    case joined = "joined"
    case bestMatch = ""
}

enum OrderType: String {
    case desc = "desc"
    case asc = "asc"
}

enum APIRouter: URLRequestConvertible {
    
    case userInfo(login: String)
    case searchUsers(query: String,
                     sort: UserSortType,
                     order: OrderType,
                     page: Int,
                     perPage: Int)

    static let baseURLString = "https://api.github.com"

    var method: HTTPMethod {
        switch self {
        case .userInfo, .searchUsers:
            return .get
        }
     }

    var path: String {
        switch self {
        case .userInfo(let login):
            return "/users/\(login)"
        case .searchUsers:
            return "/search/users"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        var queryItems = [URLQueryItem]()
        switch self {
        case .userInfo:
            return nil
        case let .searchUsers(query, sort, order, page, perPage):
            queryItems.append(URLQueryItem(name: "q", value: query))
            if sort != UserSortType.bestMatch {
                queryItems.append(URLQueryItem(name: "sort", value: sort.rawValue))
            }
            queryItems.append(URLQueryItem(name: "order", value: order.rawValue))
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
            return queryItems
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try APIRouter.baseURLString.asURL()
        
        var urlComponents = URLComponents(url: url.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        
        var urlRequest = URLRequest(url: urlComponents!.url!)
        
        urlRequest.httpMethod = method.rawValue
        
        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems
        }
        
        urlRequest.addValue(AcceptType.githubV3Json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        
        return urlRequest
    }
    
}
