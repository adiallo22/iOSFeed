//
//  CodableFeedStoreTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/11/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class CodableFeedStore {
    
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
        do {
            let decodedCache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: decodedCache.localFeed, timestamp: decodedCache.timestamp))
        } catch let error {
            completion(.failure(error))
        }
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
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieveAfterInsertingOnEmptyCache_deliversNewlyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert(feed, timestamp, to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieveAfterInsertion_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert(feed, timestamp, to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversErrorOnInvalidData() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid_data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid_data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyError()))
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
}

//MARK: - Helpers

extension CodableFeedStoreTests {
    
    private func makeSUT(storeURL: URL? = nil,
                         file: StaticString = #file,
                         line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ feed: [LocalFeedImage],
                        _ timestamp: Date,
                        to sut: CodableFeedStore,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for result")
        sut.insert(feed, timestamp: timestamp) { (insertionError) in
            XCTAssertNil(insertionError, "Expected to get nil error, but got \(String(describing: insertionError)) instead")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore,
                        toRetrieve expectedResult: RetrievedCachedResult,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for result")
        
        sut.retrieve { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
            case let (.found(expectedFeed, expectedTimestamp), .found(receivedFeed, receivedTimestamp)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, receivedTimestamp, file: file, line: line)
            default:
                XCTFail("expected to get \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
