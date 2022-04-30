//
//  UserItem+CoreDataProperties.swift
//  
//
//  Created by Eido Goya on 2022/04/30.
//
//

import Foundation
import CoreData


extension UserItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserItem> {
        return NSFetchRequest<UserItem>(entityName: "UserItem")
    }

    @NSManaged public var id: Int32
    @NSManaged public var avatarUrl: String?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var updatedAt: String?
    @NSManaged public var login: String?

}
