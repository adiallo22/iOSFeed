//
//  FeedDataLoaderWithFallbackCompositeTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/25/21.
//

import XCTest
import iOSFeed

final class FeedDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryDataLoader: FeedImageDataLoader
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
        }
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primaryDataLoader = primary
    }
    
    func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        _ = primaryDataLoader.loadImage(from: url) { _ in }
        return Task()
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
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        _ = sut.loadImage(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
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
