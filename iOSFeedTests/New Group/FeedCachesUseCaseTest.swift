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
    
    var deleteCacheFeedLoadCount = 0
    var insertCallCount = 0
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deleteCacheFeedLoadCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [Feed]) {
        insertCallCount += 1
    }
    
}

class LocalFeedLoad {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func saveOnCache(_ feeds: [Feed]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(feeds)
            }
        }
    }
}

class FeedCachesUseCaseTest: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (feed, _) = makeSUT()
        XCTAssertEqual(feed.deleteCacheFeedLoadCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (feed, sut) = makeSUT()
        let feedItems = [anyFeed(), anyFeed()]
        
        sut.saveOnCache(feedItems)
        
        XCTAssertEqual(feed.deleteCacheFeedLoadCount, 1)
    }
    
    func test_save_doesNotRequestSaveOnCacheUponDeletionError() {
        let (feed, sut) = makeSUT()
        let feedItems = [anyFeed(), anyFeed()]
        let error = anyError()
        
        sut.saveOnCache(feedItems)
        feed.completeDeletion(with: error)
        
        XCTAssertEqual(feed.insertCallCount, 0)
    }
    
    func test_save_insertItemsInCacheWhenNoDeletionError() {
        let (feed, sut) = makeSUT()
        let feedItems = [anyFeed(), anyFeed()]
        
        sut.saveOnCache(feedItems)
        feed.completeDeletionSuccessfully()
        
        XCTAssertEqual(feed.insertCallCount, 1)
    }
    
}

//MARK: - Helpers

extension FeedCachesUseCaseTest {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStore, sut: LocalFeedLoad) {
        let store = FeedStore()
        let sut = LocalFeedLoad(store: store)
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
