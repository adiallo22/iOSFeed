//
//  FeedImageStoreSpy.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 7/14/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation
import iOSFeed

class FeedImageStoreSpy: FeedImageDataStore {
    
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }
    
    private(set) var receivedMessages = [Message]()
    private var completions = [(FeedImageDataStore.RetrieveResult) -> Void]()
    
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        completions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        completions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
}
