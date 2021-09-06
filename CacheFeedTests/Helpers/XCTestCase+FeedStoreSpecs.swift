//
//  XCTestCase+FeedStoreSpecs.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/25/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
@testable import iOSFeed
import CacheFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ feed: [LocalFeedImage],
                        _ timestamp: Date,
                        to sut: FeedStore,
                        file: StaticString = #file,
                        line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for result")
        var receivedError: Error?
        sut.insert(feed, timestamp: timestamp) { (insertionError) in
            receivedError = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore,
                        file: StaticString = #file,
                        line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for result")
        var receivedError: Error?
        sut.deleteCacheFeed { (error) in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    func expect(_ sut: FeedStore,
                        toRetrieve expectedResult: RetrievedCachedResult,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for result")
        
        sut.retrieve { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(.empty), .success(.empty)),
                 (.failure, .failure):
                break
            case let (.success(.found(expectedFeed, expectedTimestamp)), .success(.found(receivedFeed, receivedTimestamp))):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, receivedTimestamp, file: file, line: line)
            default:
                XCTFail("expected to get \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
