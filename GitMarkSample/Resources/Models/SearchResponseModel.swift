//
//  SearchUserModel.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import Foundation

struct SearchResponseModel: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [UserItemModel]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items = "items"
    }
}

struct UserItemModel: Codable {
    let id: Int
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatarUrl = "avatar_url"
    }
}

struct UserInfoModel: Codable {
    let name: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
