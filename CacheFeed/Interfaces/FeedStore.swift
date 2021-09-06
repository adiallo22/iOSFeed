//
//  FeedStore.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 3/15/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public enum CachedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}
public typealias RetrievedCachedResult =  Result<CachedResult, Error>

public protocol FeedStore {
        
    typealias DeletionCompletion = (Error?) -> Void
    ///The completion handler can be invoked in any thread
    ///Client is responsible to dispatch to the appropriate thread if neccessasry
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    
    typealias InsertionCompletion = (Error?) -> Void
    ///The completion handler can be invoked in any thread
    ///Client is responsible to dispatch to the appropriate thread if neccessasry
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    typealias RetrievalCompletion = (RetrievedCachedResult) -> Void
    ///The completion handler can be invoked in any thread
    ///Client is responsible to dispatch to the appropriate thread if neccessasry
    func retrieve(completion: @escaping RetrievalCompletion)
    
}
