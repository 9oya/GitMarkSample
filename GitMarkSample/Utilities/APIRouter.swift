//
//  APIRouter.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import Alamofire

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
    
    case searchUsers(authId: String,
                     authPw: String,
                     query: String,
                     sort: UserSortType,
                     order: OrderType,
                     page: Int,
                     perPage: Int)

    static let baseURLString = "https://api.github.com"

    var method: HTTPMethod {
        switch self {
        case .searchUsers:
            return .get
        }
     }

    var path: String {
        switch self {
        case .searchUsers:
            return "/search/users"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        var queryItems = [URLQueryItem]()
        switch self {
        case let .searchUsers(_, _, query, sort, order, page, perPage):
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
        
        return urlRequest
    }
    
}
