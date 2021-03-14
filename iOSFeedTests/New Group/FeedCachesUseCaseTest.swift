//
//  FeedCachesUseCaseTest.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 3/14/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    var deletionCompletions = [DeletionCompletion]()
    
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
    
    func insert(_ items: [Feed], timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
    
}

class LocalFeedLoad {
    private let store: FeedStore
    private let currentDate: () -> Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func saveOnCache(_ feeds: [Feed], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(feeds, timestamp: self.currentDate())
            }
            completion(error)
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
        let feedItems = [anyFeed(), anyFeed()]
        let deletionError = anyError()
        let exp = expectation(description: "wait for saving")
        
        var receivedError: Error?
        sut.saveOnCache(feedItems) { error in
            receivedError = error
            exp.fulfill()
        }
        feed.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, deletionError as NSError)
    }
    
}

//MARK: - Helpers

extension FeedCachesUseCaseTest {
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file,
                 line: UInt = #line) -> (store: FeedStore, sut: LocalFeedLoad) {
        let store = FeedStore()
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
