//
//  FeedCachesUseCaseTest.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 3/14/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest

class FeedStore {
    var deleteCacheFeedLoadCount = 0
}

class LocalFeedLoad {
    init(store: FeedStore) { }
}

class FeedCachesUseCaseTest: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let feed = FeedStore()
        let sut = LocalFeedLoad(store: feed)
        XCTAssertEqual(feed.deleteCacheFeedLoadCount, 0)
    }
    
}
