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
        <#code#>
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        <#code#>
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        <#code#>
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
        <#code#>
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() {
        <#code#>
    }
    
    func test_insert_deliversErrorOnInsertionFailure() {
        <#code#>
    }
    
    func test_insert_hasNoSideEffectOnFailure() {
        <#code#>
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        <#code#>
    }
    
    func test_delete_hasNoSideEffectDeletionFailure() {
        <#code#>
    }
    
    func test_retrieve_deliversEmptyCacheOnEmptyCache() {

    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        <#code#>
    }
    
    func test_retrieveAfterInsertingOnEmptyCache_deliversNewlyInsertedCache() {
        <#code#>
    }
    
    func test_retrieveAfterInsertion_hasNoSideEffectOnEmptyCache() {
        <#code#>
    }
    
    func test_insert_overridesPreviouslyCacheValues() {
        <#code#>
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        <#code#>
    }
    
    func test_delete_esmptiesPreviouslyInsertedCache() {
        <#code#>
    }
    
    func test_operation_shouldBeRunningSerially() {
        <#code#>
    }
    
}

//MARK: - helpers

extension CoreDataFeedStoreTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CoreDaraFeedStore()
        trackForMemoryLeaks(sut)
    }
    
}
