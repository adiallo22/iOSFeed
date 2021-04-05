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
    
    func anyError() -> Error {
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
}
