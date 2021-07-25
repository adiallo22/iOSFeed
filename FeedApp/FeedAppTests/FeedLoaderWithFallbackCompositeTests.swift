//
//  RemoteWithLocalFeedLoaderTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/25/21.
//

import XCTest
import iOSFeed
import FeedApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_deliversPrimaryFeed_onPrimarySuccess() {
        let primaryFeed = uniqueItems()
        let fallbackFeed = uniqueItems()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_deliversFallback_onPrimaryFailure() {
        let fallbackFeed = uniqueItems()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_deliversError_onBothPrimaryAndFallbackFailure() {
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .failure(anyError()))
        
        expect(sut, toCompleteWith: .failure(anyError()))
    }
    
    // Mark: - Extensions
    
    private func makeSUT(primaryResult: FeedLoadResult,
                         fallbackResult: FeedLoadResult,
                         file: StaticString = #file,
                         line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let primaryLoader = FeedLoaderSpy(result: primaryResult)
        let fallbackLoader = FeedLoaderSpy(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallBack: fallbackLoader)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(primaryLoader)
        trackForMemoryLeaks(fallbackLoader)
        return sut
    }
    
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
