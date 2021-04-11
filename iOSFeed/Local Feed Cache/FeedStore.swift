//
//  FeedStore.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 3/15/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public enum RetrievedCachedResult {
    case failure(Error)
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievedCachedResult) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
    
}
