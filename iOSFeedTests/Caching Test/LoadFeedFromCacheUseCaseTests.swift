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
    
    func test_deleteCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_doesNotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_doesNotDeleteCacheOnFeedLessThanSevenDaysOld() {
        let feed = uniqueItems()
        let currentDate = Date()
        let lessThanSevenDaysOldTomestamp = currentDate.adding(days: -7).adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTomestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_DeleteCacheOnFeedMoreThanSevenDaysOld() {
        let feed = uniqueItems()
        let currentDate = Date()
        let sevenDaysOldTomestamp = currentDate.adding(days: -8)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTomestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
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
    
    func anyError() -> Error {
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    func anyURL() -> URL {
        URL(string: "http://anyurl.com")!
    }
    
    func anyFeed() -> FeedImage {
        FeedImage(id: UUID(), description: "", location: "", image: anyURL())
    }
    
    func uniqueItems() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feedItems = [anyFeed(), anyFeed()]
        let localFeedItems = feedItems.map {
            LocalFeedImage(id: $0.id,
                          description: $0.description,
                          location: $0.location,
                          image: $0.image)
        }
        return (feedItems, localFeedItems)
    }
    
}

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    func adding(seconds: Int) -> Date {
        self + 1
    }
}
