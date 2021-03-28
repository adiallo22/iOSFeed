//
//  FeedStoreSpy.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 3/28/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import iOSFeed

class FeedStoreSpy: FeedStore {
    
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    var retrievalCompletions = [InsertionCompletion]()
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    //MARK: - deletion
        
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    //MARK: - insertion
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(items, timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    //MARK: - retrieval
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](error)
    }
    
    func completeRetrievalSuccessfully(at index: Int = 0) {
        retrievalCompletions[index](nil)
    }
    
}

