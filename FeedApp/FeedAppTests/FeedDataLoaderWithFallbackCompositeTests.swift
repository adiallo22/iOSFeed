//
//  FeedDataLoaderWithFallbackCompositeTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/25/21.
//

import XCTest
import iOSFeed

final class FeedDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
        }
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
    }
    
    func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        Task()
    }
    
}

class FeedDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_deliversPrimaryFeed_onPrimarySuccess() {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        _ = FeedDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    // Mark: - Extensions
    
    private class FeedImageDataLoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: FeedImageDataLoaderResult)]()

        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }
    
}
