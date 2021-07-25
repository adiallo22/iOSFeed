//
//  RemoteWithLocalFeedLoaderTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/25/21.
//

import XCTest
import iOSFeed
import EssentialFeediOS

final class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    let fallBack: FeedLoader
    
    init(primary: FeedLoader, fallBack: FeedLoader) {
        self.primary = primary
        self.fallBack = fallBack
    }
    
    func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        primary.load { result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self.fallBack.load(completion)
            }
        }
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_deliversPrimaryFeed_onPrimarySuccess() {
        let primaryFeed = uniqueItems()
        let fallbackFeed = uniqueItems()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "wait for loading")
        sut.load { result in
            switch result {
            case .success(let receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            case .failure(let error):
                XCTFail("expected to get successull load result, but got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_deliversFallback_onPrimaryFailure() {
        let fallbackFeed = uniqueItems()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "wait for loading")
        sut.load { result in
            switch result {
            case .success(let receivedFeed):
                XCTAssertEqual(receivedFeed, fallbackFeed)
            case .failure(let error):
                XCTFail("expected to get successull load result, but got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance is supposed to be deallocated but is retained instead", file: file, line: line)
        }
    }
    
    private func uniqueItems() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "any", location: "any", image: URL(string: "any-url.com")!)]
    }
    
    private func anyError() -> Error {
        NSError(domain: "any error", code: 0, userInfo: nil)
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
