//
//  CoreDataFeedStore+FeedStore.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 7/18/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: items, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result(catching: {
                if let cache = try ManagedCache.find(in: context) {
                    return .found(feed: cache.localFeed, timestamp: cache.timestamp)
                } else {
                    return .empty
                }
            }))
        }
    }
    
}
