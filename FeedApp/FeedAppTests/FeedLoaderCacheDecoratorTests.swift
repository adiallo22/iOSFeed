//
//  FeedLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/28/21.
//

import XCTest
import iOSFeed

protocol FeedCache {
    typealias SaveResult = Error?
    func saveOnCache(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        decoratee.load { [weak self] result in
            switch result {
            case .success(let feed): self?.cache.saveOnCache(feed, completion: { _ in })
            case .failure: break
            }
            completion(result)
        }
    }
}

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
