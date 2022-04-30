//
//  UserInfoModel.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/30.
//

import Foundation

struct UserInfoModel: Codable {
    let name: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
