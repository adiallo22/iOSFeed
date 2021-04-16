//
//  CodableFeedStoreTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/11/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class CoableFeedStore {
    
    let storeURL: URL
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map {
                $0.local
            }
        }
    }
    
    private struct CodableFeedImage: Codable {
        var id: UUID
        var description: String?
        var location: String?
        var image: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.image = image.image
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, image: image)
        }
    }
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        let decoder = JSONDecoder()
        let decodedCache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: decodedCache.localFeed, timestamp: decodedCache.timestamp))
    }
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = items.map(CodableFeedImage.init)
        let encodedCache = try! encoder.encode(Cache(feed: cache, timestamp: timestamp))
        try! encodedCache.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyCacheOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for result")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("expected empty, but got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for result")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("expected retrieving twice to have no side effect and be empty, but got \(firstResult), \(secondResult)")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingOnEmptyCache_deliversNewlyInsertedCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for result")
        let feed = uniqueItems().local
        let timestamp = Date()
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected to get nil error, but got \(String(describing: insertionError)) instead")
            sut.retrieve { result in
                switch result {
                case .found(feed: let retrievedFeed, timestamp: let retrievedTimestamp):
                    XCTAssertEqual(feed, retrievedFeed)
                    XCTAssertEqual(timestamp, retrievedTimestamp)
                default:
                    XCTFail("expected found with cache \(feed) and timestamp \(timestamp), but got \(result) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}

//MARK: - Helpers

extension CodableFeedStoreTests {
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoableFeedStore {
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        let sut = CoableFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setUpEmptyStoreState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func undoStoreSideEffects() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
}
