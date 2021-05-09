//
//  FeedCacheIntegrationTests.swift
//  iOSFeedEndToEndTests
//
//  Created by Abdul Diallo on 5/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class CacheIntegrationTests: XCTestCase {
    
    func test_load_deliversNoItemEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.load { (result) in
            switch result {
            case .success(let feeds):
                XCTAssertEqual(feeds, [], "expected feeds to be empty")
            case .failure(let error):
                XCTFail("expected to get success, but got \(error) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_load_DeliversItemSavedOnSeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueItems().models
        
        let saveExp = expectation(description: "wait for save completion")
        sutToPerformSave.saveOnCache(feed) { (saveError) in
            XCTAssertNil(saveError, "expected not to get an error, but got \(saveError) instead")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        let loadExp = expectation(description: "wait for load completion")
        sutToPerformLoad.load { (result) in
            switch result {
            case .success(let feed):
                XCTAssertEqual(feed, feed)
            case .failure(let error):
                XCTFail("expected to get success, but got \(error) instead.")
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
}

