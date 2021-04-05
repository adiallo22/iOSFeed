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
        
        sut.validateCache()
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validatesCache_doesNotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validatesCache_doesNotDeleteCacheOnFeedLessThanSevenDaysOld() {
        let feed = uniqueItems()
        let currentDate = Date()
        let lessThanSevenDaysOldTomestamp = currentDate.adding(days: -7).adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTomestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_DeleteCacheOnFeedMoreThanSevenDaysOld() {
        let feed = uniqueItems()
        let currentDate = Date()
        let sevenDaysOldTomestamp = currentDate.adding(days: -8)
        let (store, sut) = makeSUT { currentDate }
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTomestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_DeleteCacheOnExactlySevenDaysOld() {
        let feed = uniqueItems()
        let currentDate = Date()
        let sevenDaysOldTomestamp = currentDate.adding(days: -7)
        let (store, sut) = makeSUT { currentDate }
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTomestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }

}

//MARK: - Helpers

extension ValidateFeedCacheUseCaseTests {
    
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
