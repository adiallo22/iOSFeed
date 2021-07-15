//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 7/14/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        completion(.success(.none))
    }
    
}
