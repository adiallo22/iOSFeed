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

final class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc func load() {
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (loader, _) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (_, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorUponLoadCompletion() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    class LoadSpy: FeedLoader {
        private var completions = [(FeedLoadResult) -> Void]()
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(_ completion: @escaping (FeedLoadResult) -> Void) {
            completions.append(completion)
        }
        
        func completeLoading() {
            completions[0](.success([]))
        }
    }
    
}

extension FeedViewControllerTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoadSpy, FeedViewController) {
        let loader = LoadSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (loader, sut)
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
