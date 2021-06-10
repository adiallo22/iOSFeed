//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Abdul Diallo on 5/31/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import UIKit
import iOSFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {
    
    func test_loadActions_RequestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
        
        sut.simulateUserInitiatedFeedRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
        
        sut.simulateUserInitiatedFeedRefresh()
        XCTAssertEqual(loader.loadFeedCallCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadongFeed() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
        
        sut.simulateUserInitiatedFeedRefresh()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeLoading(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadCompletes_RenderSuccessfullyLoadedFeed() {
        let (loader, sut) = makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "a location")
        let image2 = makeImage(description: nil, location: nil)
        let image3 = makeImage(description: "a description", location: nil)

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedRefresh()
        
        loader.completeLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentStateRenderingAfterError() {
        let (loader, sut) = makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedRefresh()
        loader.completeLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)

        sut.simulateUserInitiatedFeedRefresh()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeLoadingWithError(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "any-url"))
        let image1 = makeImage(url: URL(string: "any-url1"))
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "expected no img url until view becomes visible")
        
        sut.simulateFeedImageVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.image], "expected first image url once view becomes visible")
        
        sut.simulateFeedImageVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.image, image1.image], "expected both image urls once view becomes visible")
    }
    
    func test_feedImageView_cancelLoadsImageURLWhenNotVisible() {
        let image0 = makeImage(url: URL(string: "any-url"))
        let image1 = makeImage(url: URL(string: "any-url1"))
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.cancelledImageURLs, [], "expected no cancel img url until view is not visible")
        
        sut.simulateFeedImageNOTVisible()
        XCTAssertEqual(loader.cancelledImageURLs, [image0.image], "expected one cancel image url once view is not visible")
        
        sut.simulateFeedImageNOTVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.image, image1.image], "expected both cancel image urls once view is not visible")
    }
    
    class LoadSpy: FeedLoader, FeedImageDataLoader {
        
        //MARK: - FeedLoader
        
        private var feedRequests = [(FeedLoadResult) -> Void]()
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
                
        func load(_ completion: @escaping (FeedLoadResult) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        //MARK: - FeedImageDataLoader
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelledCallback: () -> Void
            func cancel() {
                cancelledCallback()
            }
        }

        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()

        func loadImage(from url: URL) -> FeedImageDataLoaderTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
    }
    
}

extension FeedViewControllerTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoadSpy, FeedViewController) {
        let loader = LoadSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (loader, sut)
    }
    
    func makeImage(url: URL? = URL(string: "any-url"), description: String? = nil, location: String? = nil) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, image: url!)
    }
    
    func assertThat(_ sut: FeedViewController,
                    hasviewConfiguredFor image: FeedImage,
                    at index: Int,
                    file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, but got \(String(describing: view)) instead", file: file, line: line)
        }
        XCTAssertEqual(cell.isShowingLocation, image.location != nil,
                       "expected `isShowingLocation` to be \(String(image.location != nil)) for view at \(index)", file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location,
                       "expected location to be \(String(describing: image.location)) for view at \(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description,
                       "expected description to be \(String(describing: image.description)) for view at \(index)", file: file, line: line)
    }
    
    func assertThat(_ sut: FeedViewController,
                    isRendering feed: [FeedImage],
                    file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedImageFeeds() == feed.count else {
            return XCTFail("Expected \(feed.count) images, but got \(sut.numberOfRenderedImageFeeds())", file: file, line: line)
        }
        feed.enumerated().forEach { (index, image) in
            assertThat(sut, hasviewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedRefresh() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool? {
        refreshControl?.isRefreshing
    }
    
    func numberOfRenderedImageFeeds() -> Int {
        tableView.numberOfRows(inSection: feedImageSections)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSections)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSections: Int {
        0
    }
    
    @discardableResult
    func simulateFeedImageVisible(at index: Int = 0) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageNOTVisible(at index: Int = 0) {
        let view = simulateFeedImageVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImageSections)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ (target) in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}
