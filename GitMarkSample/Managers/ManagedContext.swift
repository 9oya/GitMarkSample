//
//  ManagedContext.swift
//  GitMarkSample
//
//  Created by Eido Goya on 2022/04/29.
//

import CoreData

protocol ManagedContextProtocol {
    
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult
    
    func performAndWait(_ block: () -> Void)
    
    func save() throws
    
    func delete(_ object: NSManagedObject)
    
}

extension NSManagedObjectContext: ManagedContextProtocol {
}
