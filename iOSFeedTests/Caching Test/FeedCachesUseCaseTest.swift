//
//  FeedCachesUseCaseTest.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 3/14/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class FeedCachesUseCaseTest: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (feed, _) = makeSUT()
        XCTAssertEqual(feed.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (feed, sut) = makeSUT()
        
        sut.saveOnCache(uniqueItems().models) { _ in }
        
        XCTAssertEqual(feed.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestSaveOnCacheUponDeletionError() {
        let (feed, sut) = makeSUT()
        let error = anyError()
        
        sut.saveOnCache(uniqueItems().models) { _ in }
        feed.completeDeletion(with: error)
        
        XCTAssertEqual(feed.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_insertItemsInCacheWithTimeStampWhenNoDeletionError() {
        let timestamp = Date()
        let (feed, sut) = makeSUT { timestamp }
        let items = uniqueItems()
        
        sut.saveOnCache(items.models) { _ in }
        feed.completeDeletionSuccessfully()
        
        XCTAssertEqual(feed.receivedMessages, [.deleteCacheFeed, .insert(items.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (feed, sut) = makeSUT()
        let deletionError = anyError()
        
        expect(sut, toCompleteWithError: deletionError as NSError) {
            feed.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionnError() {
        let (feed, sut) = makeSUT()
        let insertionError = anyError()
        
        expect(sut, toCompleteWithError: insertionError as NSError) {
            feed.completeDeletionSuccessfully()
            feed.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_sucessIfNoError() {
        let (feed, sut) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            feed.completeDeletionSuccessfully()
            feed.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorWhenSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.saveOnCache(uniqueItems().models) { receivedResults.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorWhenSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.saveOnCache(uniqueItems().models) { receivedResults.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
}

//MARK: - Helpers

extension FeedCachesUseCaseTest {
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWithError expectedError: NSError?,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for saving")
        
        var receivedError: Error?
        sut.saveOnCache([anyFeed()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
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
