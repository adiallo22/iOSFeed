//
//  LoadFeedFromCacheUseCaseTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 3/28/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed
import CacheFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_requestCacheRetrievalFailsWithError() {
        let (store, sut) = makeSUT()
        let retreivedError = anyError()
        
        expect(sut, toCompleteWith: .failure(retreivedError)) {
            store.completeRetrieval(with: retreivedError)
        }
    }
    
    func test_load_deliversNoFeedOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalSuccessfully()
        }
    }
    
    func test_load_deliversCachedImagesOnNonExpiredCache() {
        let feed = uniqueItems()
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusFeedChacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let feed = uniqueItems()
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedChacheMaxAge().adding(days: -1)
        let (store, sut) = makeSUT { currentDate }
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        }
    }
    
    //in the below cases, side effect is refering to deleting cache; so we should expect no deletion
    
    func test_load_doesNotHaveSideEffectOnRetrievalError() {
        let (store, sut) = makeSUT()
        sut.load { _ in }
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache() {
        let feed = uniqueItems()
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusFeedChacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let feed = uniqueItems()
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusFeedChacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnExactExpiration() {
        let feed = uniqueItems()
        let currentDate = Date()
        let exactExpirationTimestamp = currentDate.minusFeedChacheMaxAge()
        let (store, sut) = makeSUT { currentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: exactExpirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstancehasBeenDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [FeedLoadResult]()
        sut?.load({ receivedResult.append($0) })
        sut = nil
        store.completeRetrievalSuccessfully()
        
        XCTAssertTrue(receivedResult.isEmpty)
        
    }

}

//MARK: - Helpers

extension LoadFeedFromCacheUseCaseTests {
    
    func expect(_ sut: LocalFeedLoader,
                toCompleteWith expectedResult: FeedLoadResult,
                when action: () -> Void,
                file: StaticString = #file,
                line: UInt = #line) {
        let exp = expectation(description: "wait for result")

        sut.load { (receivedResult) in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("expected to get \(expectedResult), but got \(receivedResult)")
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file,
                 line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }
    
}
