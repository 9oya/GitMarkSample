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
