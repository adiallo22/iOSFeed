//
//  ValidateFeedCacheUseCaseTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/4/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validatesCache_deleteCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validatesCache_doesNotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrievalSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validatesCache_doesNotDeleteCacheOnNonExpiredCache() {
        let feed = uniqueItems()
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusFeedChacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_DeleteCacheOnExpiredCache() {
        let feed = uniqueItems()
        let currentDate = Date()
        let expiredTimestamp = currentDate.adding(days: -8)
        let (store, sut) = makeSUT { currentDate }
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_DeleteCacheOnExactExpiration() {
        let feed = uniqueItems()
        let currentDate = Date()
        let exactExpirationTimestamp = currentDate.minusFeedChacheMaxAge()
        let (store, sut) = makeSUT { currentDate }
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: exactExpirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_DoesNotDeleteCacheAfterInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache { _ in }
        
        sut = nil
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (store, sut) = makeSUT()
        let deletionError = anyError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: anyError())
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: anyError())
            store.completeDeletionSuccessfully()
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedChacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        })
    }
    
}

//MARK: - Helpers

extension ValidateFeedCacheUseCaseTests {
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file,
                 line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWith expectedResult: LocalFeedLoader.ValidationResult,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}
