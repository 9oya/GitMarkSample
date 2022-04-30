//
//  ManagerProvider.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import UIKit
import Kingfisher
import Alamofire
import CoreData

protocol ManagerProviderProtocol {
    
    var managedContext: ManagedContextProtocol { get }
    var cacheManager: CacheManagerProtocol { get }
    
}

struct ManagerProvider: ManagerProviderProtocol {
    
    var managedContext: ManagedContextProtocol
    var cacheManager: CacheManagerProtocol
    
    static func resolve() -> ManagerProviderProtocol {
        
        let cacheManager: KingfisherManager = KingfisherManager.shared
        let storeContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "GitMarkSample")
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
        let managedContext: ManagedContextProtocol = storeContainer.viewContext
        
        return ManagerProvider(
            managedContext: managedContext,
            cacheManager: cacheManager
        )
    }
    
}
