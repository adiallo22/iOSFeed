//
//  FeedCachesUseCaseTest.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 3/14/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [Feed], timestamp: Date, completion: @escaping InsertionCompletion)
}

class FeedStoreSpy: FeedStore {
    
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([Feed], Date)
    }
        
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [Feed], timestamp: Date, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(items, timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
}

class LocalFeedLoad {
    private let store: FeedStoreSpy
    private let currentDate: () -> Date
    init(store: FeedStoreSpy, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func saveOnCache(_ feeds: [Feed], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(feeds, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedCachesUseCaseTest: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (feed, _) = makeSUT()
        XCTAssertEqual(feed.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (feed, sut) = makeSUT()
        let feedItems = [anyFeed(), anyFeed()]
        
        sut.saveOnCache(feedItems) { _ in }
        
        XCTAssertEqual(feed.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestSaveOnCacheUponDeletionError() {
        let (feed, sut) = makeSUT()
        let feedItems = [anyFeed(), anyFeed()]
        let error = anyError()
        
        sut.saveOnCache(feedItems) { _ in }
        feed.completeDeletion(with: error)
        
        XCTAssertEqual(feed.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_insertItemsInCacheWithTimeStampWhenNoDeletionError() {
        let timestamp = Date()
        let (feed, sut) = makeSUT { timestamp }
        let feedItems = [anyFeed(), anyFeed()]
        
        sut.saveOnCache(feedItems) { _ in }
        feed.completeDeletionSuccessfully()
        
        XCTAssertEqual(feed.receivedMessages, [.deleteCacheFeed, .insert(feedItems, timestamp)])
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
    
}

//MARK: - Helpers

extension FeedCachesUseCaseTest {
    
    private func expect(_ sut: LocalFeedLoad,
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
                 line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoad) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoad(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }
    
    func anyURL() -> URL {
        URL(string: "http://anyurl.com")!
    }
    
    func anyFeed() -> Feed {
        Feed(id: UUID(), description: "", location: "", image: anyURL())
    }
    
    func anyError() -> Error {
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
}
