//
//  FeedLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/28/21.
//

import XCTest
import iOSFeed

final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        decoratee.load(completion)
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueItems()
        let loader = FeedLoaderSpy(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)

        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let feed = uniqueItems()
        let loader = FeedLoaderSpy(result: .failure(anyError()))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)

        expect(sut, toCompleteWith: .failure(anyError()))
    }
    
    // MARK: - Helpers
    
    private func expect(_ sut: FeedLoader,
                        toCompleteWith expectedResult: FeedLoadResult,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class FeedLoaderSpy: FeedLoader {
        var result: FeedLoadResult
        
        init(result: FeedLoadResult) {
            self.result = result
        }
        
        func load(_ completion: @escaping (FeedLoadResult) -> Void) {
            completion(result)
        }
    }
    
}
