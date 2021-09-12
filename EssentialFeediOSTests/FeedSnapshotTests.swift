//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Abdul Diallo on 8/23/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import UIKit
import iOSFeed
import EssentialFeediOS

class FeedSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        let _ = makeSUT()
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> FeedViewController {
        let controller = FeedViewController(nibName: nil, bundle: nil)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = controller
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
}
