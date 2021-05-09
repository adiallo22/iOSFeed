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
    
    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_DeliversItemSavedOnSeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueItems().models
        
        save(feed, on: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_load_overridesItemSavedOnAnotherInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueItems().models
        let lastFeed = uniqueItems().models
        
        save(firstFeed, on: sutToPerformFirstSave)
        save(lastFeed, on: sutToPerformLastSave)
        
        expect(sutToPerformLoad, toLoad: lastFeed)

    }
    
}

//MARK: - Helpers

extension CacheIntegrationTests {
    func expect(_ sut: LocalFeedLoader,
                toLoad expectedFeed: [FeedImage],
                file: StaticString = #file,
                line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        sut.load { (result) in
            switch result {
            case .success(let loadedFeed):
                XCTAssertEqual(loadedFeed,expectedFeed, file: file, line: line)
            case .failure(let error):
                XCTFail("expected to get success, but got \(error) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func save(_ feed: [FeedImage],
              on sut: LocalFeedLoader,
              file: StaticString = #file,
              line: UInt = #line) {
        let exp = expectation(description: "wait for saving")
        sut.saveOnCache(feed) { (saveError) in
            XCTAssertNil(saveError,
                         "expected not to get an error, but got \(String(describing: saveError)) instead")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}

extension CacheIntegrationTests {
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
    
    private func setUpEmptyStoreState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func undoStoreSideEffects() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
