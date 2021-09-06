//
//  CoreDataFeedStoreTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/29/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
@testable import iOSFeed
import CacheFeed

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
//        let sut = makeSUT()
//
//        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
//        let sut = makeSUT()
//
//        expect(sut, toRetrieve: .success(.empty))
//        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_retrieveAfterInsertingOnEmptyCache_deliversNewlyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert(feed, timestamp, to: sut)
        
        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)))
    }
    
    func test_retrieveAfterInsertion_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert(feed, timestamp, to: sut)
        
        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)))
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
        let sut = makeSUT()
        insert(uniqueItems().local, Date(), to: sut)
        
        let newFeed = uniqueItems().local
        let newTimestamp = Date()
        insert(newFeed, newTimestamp, to: sut)
        
        expect(sut, toRetrieve: .success(.found(feed: newFeed, timestamp: newTimestamp)))
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert(uniqueItems().local, Date(), to: sut)
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "expected to get nil error, but got \(String(describing: deletionError)) instead")
    }
    
    func test_delete_esmptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert(uniqueItems().local, Date(), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_operation_shouldBeRunningSerially() {
        let sut = makeSUT()
        var operations = [XCTestExpectation]()
        
        let op1 = expectation(description: "wait for operation 1")
        sut.insert(uniqueItems().local, timestamp: Date()) { (_) in
            operations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "wait for operation 2")
        sut.deleteCacheFeed { (_) in
            operations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "wait for operation 3")
        sut.insert(uniqueItems().local, timestamp: Date()) { (_) in
            operations.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(operations, [op1, op2, op3])
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
