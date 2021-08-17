//
//  FeedAppUITests.swift
//  FeedAppUITests
//
//  Created by Abdul Diallo on 8/8/21.
//

import XCTest

class FeedAppUITests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWithCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
    func test_onLaunch_displaysCachedFeedWithCustomerHasNOConnectivity() {
        let online = XCUIApplication()
        online.launchArguments = ["-reset", "-connectivity", "online"]
        online.launch()

        let offline = XCUIApplication()
        offline.launchArguments = ["-connectivity", "offline"]
        offline.launch()

        let feedCells = offline.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)

        let firstImage = offline.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
    func test_displaysEmptyFeed_onNoConnectivityAndNoCache() {
        let offline = XCUIApplication()
        offline.launchArguments = ["-reset", "-connectivity", "offline"]
        offline.launch()
        
        let feedCells = offline.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 0)
    }
}
