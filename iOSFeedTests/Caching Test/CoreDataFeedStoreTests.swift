//
//  CoreDataFeedStoreTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/29/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
@testable import iOSFeed

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
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert(feed, timestamp, to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieveAfterInsertion_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert(feed, timestamp, to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert(uniqueItems().local, Date(), to: sut)
        
        XCTAssertNil(insertionError, "expected to receive nil but got \(String(describing: insertionError)) instead")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert(uniqueItems().local, Date(), to: sut)
        let insertionError = insert(uniqueItems().local, Date(), to: sut)
        
        XCTAssertNil(insertionError, "expected to receive nil but got \(String(describing: insertionError)) instead")
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
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}
