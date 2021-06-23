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

class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (_, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_loadCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "wait for background queue")
        DispatchQueue.global().async {
            loader.completeLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
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
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage(), makeImage()])
        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingLoadingImageIndicator, true, "expected to show loading img indicator")
        XCTAssertEqual(view1?.isShowingLoadingImageIndicator, true, "expected to show loading img indicator")

        loader.completeImageLoader(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingImageIndicator, false, "expected NOT to show loading img indicator")
        XCTAssertEqual(view1?.isShowingLoadingImageIndicator, true, "expected to show loading img indicator")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingImageIndicator, false, "expected NOT to show loading img indicator")
        XCTAssertEqual(view1?.isShowingLoadingImageIndicator, false, "expected NOT to show loading img indicator")

    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage(), makeImage()])
        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingLoadingImageIndicator, true, "expected to show loading img indicator")
        XCTAssertEqual(view1?.isShowingLoadingImageIndicator, true, "expected to show loading img indicator")

        loader.completeImageLoader(at: 0)
        XCTAssertEqual(view0?.renderedImage, .none, "expected no image")
        XCTAssertEqual(view1?.renderedImage, .none, "expected no image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoader(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "expected image to be rendered for first")
        XCTAssertEqual(view1?.renderedImage, .none, "expected no image")
        
        let imageData1 = UIImage.make(withColor: .orange).pngData()!
        loader.completeImageLoader(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "expected image to be rendered for first")
        XCTAssertEqual(view1?.renderedImage, imageData1, "expected image to be rendered for second")

    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoader(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
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
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
             let image0 = makeImage(url: URL(string: "http://url-0.com")!)
             let image1 = makeImage(url: URL(string: "http://url-1.com")!)
             let (loader, sut) = makeSUT()

             sut.loadViewIfNeeded()
             loader.completeLoading(with: [image0, image1])

             let view0 = sut.simulateFeedImageVisible(at: 0)
             let view1 = sut.simulateFeedImageVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.image, image1.image], "Expected two image URL request for the two visible views")

             loader.completeImageLoadingWithError(at: 0)
             loader.completeImageLoadingWithError(at: 1)
             XCTAssertEqual(loader.loadedImageURLs, [image0.image, image1.image], "Expected only two image URL requests before retry action")

             view0?.simulateRetryAction()
             XCTAssertEqual(loader.loadedImageURLs, [image0.image, image1.image, image0.image], "Expected third imageURL request after first view retry action")

             view1?.simulateRetryAction()
             XCTAssertEqual(loader.loadedImageURLs, [image0.image, image1.image, image0.image, image1.image], "Expected fourth imageURL request after second view retry action")
         }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoader(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.image], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.image, image1.image], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.image], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.image, image1.image], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_feedImageView_doesNotRenderLoadedImageViewWhenNotVisibleAnymore() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageNOTVisible()
        loader.completeImageLoader(with: UIImage.make(withColor: .red).pngData()!)
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
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
        
        private var imageRequests = [(url: URL, completion: FeedImageDataLoaderResult)]()

        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()

        func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoader(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "", code: 0)
            imageRequests[index].completion(.failure(error))
        }
        
    }
    
}

extension FeedUIIntegrationTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoadSpy, FeedViewController) {
        let loader = LoadSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
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
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
    
    var isShowingLoadingImageIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
}

private extension FeedViewController {
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSections)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSections)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
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
    
    @discardableResult
    func simulateFeedImageNOTVisible(at index: Int = 0) -> FeedImageCell? {
        let view = simulateFeedImageVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImageSections)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        
        return view
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

private extension UIImage {
     static func make(withColor color: UIColor) -> UIImage {
         let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
         UIGraphicsBeginImageContext(rect.size)
         let context = UIGraphicsGetCurrentContext()!
         context.setFillColor(color.cgColor)
         context.fill(rect)
         let img = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         return img!
     }
 }

private extension UIButton {
     func simulateTap() {
         allTargets.forEach { target in
             actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                 (target as NSObject).perform(Selector($0))
             }
         }
     }
 }
