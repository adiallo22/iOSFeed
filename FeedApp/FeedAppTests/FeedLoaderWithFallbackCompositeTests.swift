//
//  RemoteWithLocalFeedLoaderTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/25/21.
//

import XCTest
import iOSFeed
import FeedApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    
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
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallBack: fallbackLoader)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(primaryLoader)
        trackForMemoryLeaks(fallbackLoader)
        return sut
    }
    
}
