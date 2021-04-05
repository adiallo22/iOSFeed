//
//  LoadFeedFromCacheUseCaseTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 3/28/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

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
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueItems()
        let currentDate = Date()
        let lessThanSevenDaysOldTomestamp = currentDate.adding(days: -7).adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTomestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueItems()
        let currentDate = Date()
        let moreThanSevenDaysTimestamp = currentDate.adding(days: -8)
        let (store, sut) = makeSUT { currentDate }
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysTimestamp)
        }
    }
    
    func test_load_doesNotHaveSideEffectOnRetrievalError() {
        let (store, sut) = makeSUT()
        //in this case side effect refers to deleting cache
        sut.load { _ in }
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        // in this case side effect is refering to deleting cache
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnFeedLessThanSevenDaysOld() {
        // in this case side effect is refering to deleting cache
        let feed = uniqueItems()
        let currentDate = Date()
        let lessThanSevenDaysOldTomestamp = currentDate.adding(days: -7).adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTomestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_DeleteCacheOnFeedMoreThanSevenDaysOld() {
        let feed = uniqueItems()
        let currentDate = Date()
        let sevenDaysOldTomestamp = currentDate.adding(days: -8)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTomestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstancehasBeenDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoad? = LocalFeedLoad(store: store, currentDate: Date.init)
        
        var receivedResult = [FeedLoadResult]()
        sut?.load({ receivedResult.append($0) })
        sut = nil
        store.completeRetrievalSuccessfully()
        
        XCTAssertTrue(receivedResult.isEmpty)
        
    }

}

//MARK: - Helpers

extension LoadFeedFromCacheUseCaseTests {
    
    func expect(_ sut: LocalFeedLoad,
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
                 line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoad) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoad(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }
    
}
