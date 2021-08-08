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
        
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 6)
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
}
