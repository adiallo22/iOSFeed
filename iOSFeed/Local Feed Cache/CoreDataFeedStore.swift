//
//  CoreDataFeedStore.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 4/29/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import CoreData
import Foundation

class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", in: bundle)
        context = container.newBackgroundContext()
    }
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

private extension NSPersistentContainer {
     enum LoadingError: Swift.Error {
         case modelNotFound
         case failedToLoadPersistentStores(Swift.Error)
     }

     static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
         guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
             throw LoadingError.modelNotFound
         }

         let container = NSPersistentContainer(name: name, managedObjectModel: model)
         var loadError: Swift.Error?
         container.loadPersistentStores { loadError = $1 }
         try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }

         return container
     }
 }

 private extension NSManagedObjectModel {
     static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
         return bundle
             .url(forResource: name, withExtension: "momd")
             .flatMap { NSManagedObjectModel(contentsOf: $0) }
     }
 }
