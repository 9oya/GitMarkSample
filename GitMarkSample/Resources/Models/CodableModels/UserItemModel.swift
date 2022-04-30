//
//  UserItemModel.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/30.
//

import Foundation

struct UserItemModel: Codable {
    let login: String
    let id: Int
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case login = "login"
        case id = "id"
        case avatarUrl = "avatar_url"
    }
}
