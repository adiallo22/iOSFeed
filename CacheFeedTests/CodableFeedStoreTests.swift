////
////  CodableFeedStoreTests.swift
////  iOSFeedTests
////
////  Created by Abdul Diallo on 4/11/21.
////  Copyright © 2021 Abdul Diallo. All rights reserved.
////
//
//import XCTest
//import iOSFeed
//import CacheFeed
//
//class CodableFeedStoreTests: XCTestCase, FailableSpecs {
//
//    override func setUp() {
//        super.setUp()
//        setUpEmptyStoreState()
//    }
//
//    override func tearDown() {
//        super.tearDown()
//        undoStoreSideEffects()
//    }
//
//    func test_retrieve_deliversEmptyCacheOnEmptyCache() {
//        let sut = makeSUT()
//        expect(sut, toRetrieve: .success(.empty))
//    }
//
//    func test_retrieve_hasNoSideEffectOnEmptyCache() {
//        let sut = makeSUT()
//        expect(sut, toRetrieve: .success(.empty))
//        expect(sut, toRetrieve: .success(.empty))
//    }
//
//    func test_retrieveAfterInsertingOnEmptyCache_deliversNewlyInsertedCache() {
//        let sut = makeSUT()
//        let feed = uniqueItems().local
//        let timestamp = Date()
//
//        insert(feed, timestamp, to: sut)
//
//        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)))
//    }
//
//    func test_retrieveAfterInsertion_hasNoSideEffectOnEmptyCache() {
//        let sut = makeSUT()
//        let feed = uniqueItems().local
//        let timestamp = Date()
//
//        insert(feed, timestamp, to: sut)
//
//        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)))
//        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)))
//    }
//
//    func test_retrieve_deliversErrorOnInvalidData() {
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(storeURL: storeURL)
//        try? "invalid_data".write(to: storeURL, atomically: false, encoding: .utf8)
//        expect(sut, toRetrieve: .failure(anyError()))
//    }
//
//    func test_retrieve_hasNoSideEffectOnFailure() {
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(storeURL: storeURL)
//        try? "invalid_data".write(to: storeURL, atomically: false, encoding: .utf8)
//        expect(sut, toRetrieve: .failure(anyError()))
//        expect(sut, toRetrieve: .failure(anyError()))
//    }
//
//    func test_insert_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//
//        let insertionError = insert(uniqueItems().local, Date(), to: sut)
//
//        XCTAssertNil(insertionError, "expected to receive nil but got \(String(describing: insertionError)) instead")
//    }
//
//    func test_insert_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        insert(uniqueItems().local, Date(), to: sut)
//        let insertionError = insert(uniqueItems().local, Date(), to: sut)
//
//        XCTAssertNil(insertionError, "expected to receive nil but got \(String(describing: insertionError)) instead")
//    }
//
//    func test_insert_overridesPreviouslyCacheValues() {
//        let sut = makeSUT()
//        let firstInsertionError = insert(uniqueItems().local, Date(), to: sut)
//        XCTAssertNil(firstInsertionError, "Expected insertion to be successfull")
//
//        let latestFeed = uniqueItems().local
//        let latestTimestamp = Date()
//        let latestInsertionError = insert(latestFeed, latestTimestamp, to: sut)
//        XCTAssertNil(latestInsertionError, "Expected insertion to be successfull")
//
//        expect(sut, toRetrieve: .success(.found(feed: latestFeed, timestamp: latestTimestamp)))
//    }
//
//    func test_insert_deliversErrorOnInsertionFailure() {
//        let invalidStoreURL = URL(string: "whatever://store-url")!
//        let sut = makeSUT(storeURL: invalidStoreURL)
//        let feed = uniqueItems().local
//        let timestamp = Date()
//
//        let insertionError = insert(feed, timestamp, to: sut)
//
//        XCTAssertNotNil(insertionError, "expected cache insertion to fail with an error")
//    }
//
//    func test_insert_hasNoSideEffectOnFailure() {
//        let invalidStoreURL = URL(string: "whatever://store-url")!
//        let sut = makeSUT(storeURL: invalidStoreURL)
//        let feed = uniqueItems().local
//        let timestamp = Date()
//
//        insert(feed, timestamp, to: sut)
//
//        expect(sut, toRetrieve: .success(.empty))
//    }
//
//    func test_delete_hasNoSideEffectsOnEmptyCache() {
//        let sut = makeSUT()
//
//        let deletionError = deleteCache(from: sut)
//        XCTAssertNil(deletionError, "Expected deletion to be successfull")
//
//        expect(sut, toRetrieve: .success(.empty))
//        expect(sut, toRetrieve: .success(.empty))
//    }
//
//    func test_delete_esmptiesPreviouslyInsertedCache() {
//        let sut = makeSUT()
//
//        let insertionError = insert(uniqueItems().local, Date(), to: sut)
//        XCTAssertNil(insertionError, "Expected insertion to be successfull")
//        let deletionError = deleteCache(from: sut)
//        XCTAssertNil(deletionError, "Expected deletion to be successfull")
//
//        expect(sut, toRetrieve: .success(.empty))
//    }
//
//    func test_delete_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        insert(uniqueItems().local, Date(), to: sut)
//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNil(deletionError, "expected to get nil error, but got \(String(describing: deletionError)) instead")
//    }
//
//    func test_delete_deliversErrorOnDeletionError() {
//        let nonDeleteCachePermission = noDeletePermissionURL()
//        let sut = makeSUT(storeURL: nonDeleteCachePermission)
//
//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNotNil(deletionError, "Expected deletion to fail")
//        expect(sut, toRetrieve: .success(.empty))
//    }
//
//    func test_delete_hasNoSideEffectDeletionFailure() {
//        let nonDeleteCachePermission = cachesDirectory()
//        let sut = makeSUT(storeURL: nonDeleteCachePermission)
//
//        deleteCache(from: sut)
//
//        expect(sut, toRetrieve: .success(.empty))
//    }
//
//    func test_operation_shouldBeRunningSerially() {
//        let sut = makeSUT()
//        var operations = [XCTestExpectation]()
//
//        let op1 = expectation(description: "wait for operation 1")
//        sut.insert(uniqueItems().local, timestamp: Date()) { (_) in
//            operations.append(op1)
//            op1.fulfill()
//        }
//
//        let op2 = expectation(description: "wait for operation 2")
//        sut.deleteCacheFeed { (_) in
//            operations.append(op2)
//            op2.fulfill()
//        }
//
//        let op3 = expectation(description: "wait for operation 3")
//        sut.insert(uniqueItems().local, timestamp: Date()) { (_) in
//            operations.append(op3)
//            op3.fulfill()
//        }
//
//        waitForExpectations(timeout: 5.0)
//        XCTAssertEqual(operations, [op1, op2, op3])
//    }
//
//}
//
////MARK: - Helpers
//
//extension CodableFeedStoreTests {
//
//    private func makeSUT(storeURL: URL? = nil,
//                         file: StaticString = #file,
//                         line: UInt = #line) -> FeedStore {
//        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
//        trackForMemoryLeaks(sut, file: file, line: line)
//        return sut
//    }
//
//    private func testSpecificStoreURL() -> URL {
//        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
//    }
//
//    private func cachesDirectory() -> URL {
//             return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
//         }
//
//    private func setUpEmptyStoreState() {
//        try? FileManager.default.removeItem(at: testSpecificStoreURL())
//    }
//
//    private func undoStoreSideEffects() {
//        try? FileManager.default.removeItem(at: testSpecificStoreURL())
//    }
//
//    private func noDeletePermissionURL() -> URL {
//        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
//    }
//
//}
