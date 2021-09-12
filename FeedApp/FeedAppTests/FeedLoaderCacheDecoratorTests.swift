//
//  FeedLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/28/21.
//

import XCTest
import iOSFeed
import FeedApp
import CacheFeed

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueItems()
        let sut = makeSUT(loaderResult: .success(feed))

        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyError()))

        expect(sut, toCompleteWith: .failure(anyError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let feed = uniqueItems()
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)], "expected to cache loaded feed on success")
    }
    
    func test_load_doesNotcachesLoadedFeedOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyError()), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty, "expected not to cache feed upon failure")
    }
    
    // Mark: - Helpers
    
    private func makeSUT(loaderResult: FeedLoadResult,
                         cache: CacheSpy = .init(),
                         file: StaticString = #file,
                         line: UInt = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        private (set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func saveOnCache(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(feeds))
            completion(.none)
        }
    }
    
}
