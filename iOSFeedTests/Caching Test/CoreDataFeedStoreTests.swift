//
//  CoreDataFeedStoreTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/29/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class CoreDaraFeedStore: FeedStore {
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

class CoreDataFeedStoreTests: XCTestCase, FailableSpecs {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_retrieve_deliversErrorOnInvalidData() {
        
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() {
        
    }
    
    func test_insert_deliversErrorOnInsertionFailure() {
        
    }
    
    func test_insert_hasNoSideEffectOnFailure() {
        
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        
    }
    
    func test_delete_hasNoSideEffectDeletionFailure() {
        
    }
    
    func test_retrieve_deliversEmptyCacheOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieveAfterInsertingOnEmptyCache_deliversNewlyInsertedCache() {
        
    }
    
    func test_retrieveAfterInsertion_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyCacheValues() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_esmptiesPreviouslyInsertedCache() {
        
    }
    
    func test_operation_shouldBeRunningSerially() {
        
    }
    
}

//MARK: - helpers

extension CoreDataFeedStoreTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CoreDaraFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}
