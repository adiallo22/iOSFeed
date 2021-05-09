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
        
        let saveExp = expectation(description: "wait for save completion")
        sutToPerformSave.saveOnCache(feed) { (saveError) in
            XCTAssertNil(saveError,
                         "expected not to get an error, but got \(String(describing: saveError)) instead")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_load_overridesItemSavedOnAnotherInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueItems().models
        let lastFeed = uniqueItems().models
        
        let firstExp = expectation(description: "wait for first saving")
        sutToPerformFirstSave.saveOnCache(firstFeed) { (saveError) in
            XCTAssertNil(saveError,
                         "expected not to get an error, but got \(String(describing: saveError)) instead")
            firstExp.fulfill()
        }
        wait(for: [firstExp], timeout: 1.0)
        
        let lastExp = expectation(description: "wait for first saving")
        sutToPerformLastSave.saveOnCache(lastFeed) { (saveError) in
            XCTAssertNil(saveError,
                         "expected not to get an error, but got \(String(describing: saveError)) instead")
            lastExp.fulfill()
        }
        wait(for: [lastExp], timeout: 1.0)
        
        expect(sutToPerformLoad, toLoad: lastFeed)

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

