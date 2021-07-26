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
    private let fallbackDataLoader: FeedImageDataLoader
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
        }
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primaryDataLoader = primary
        self.fallbackDataLoader = fallback
    }
    
    func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        _ = primaryDataLoader.loadImage(from: url) { [weak self] result in
            switch result {
            case .success:
                break
                
            case .failure:
                _ = self?.fallbackDataLoader.loadImage(from: url) { _ in }
            }
        }
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
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImage(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        _ = sut.loadImage(from: url) { _ in }

        primaryLoader.complete(with: anyError())

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
    }
    
    // Mark: - Extensions
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: FeedImageDataLoader,
                                                 primary: FeedImageDataLoaderSpy,
                                                 fallback: FeedImageDataLoaderSpy) {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
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
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
    
}
