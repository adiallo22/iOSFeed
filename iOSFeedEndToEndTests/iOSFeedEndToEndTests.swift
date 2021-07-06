//
//  iOSFeedEndToEndTests.swift
//  iOSFeedEndToEndTests
//
//  Created by Abdul Diallo on 3/1/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class iOSFeedEndToEndTests: XCTestCase {
    
    func test_EndToEndServerGetFeedResult_matchesFixedTestAccountData() {
        let expectedResult = getFeedResult()
        switch expectedResult {
        case .success(let items):
            XCTAssertEqual(items.count, 8)
            XCTAssertEqual(items[0], expectedItem(at: 0))
            XCTAssertEqual(items[1], expectedItem(at: 1))
            XCTAssertEqual(items[2], expectedItem(at: 2))
            XCTAssertEqual(items[3], expectedItem(at: 3))
            XCTAssertEqual(items[4], expectedItem(at: 4))
            XCTAssertEqual(items[5], expectedItem(at: 5))
            XCTAssertEqual(items[6], expectedItem(at: 6))
            XCTAssertEqual(items[7], expectedItem(at: 7))
        case .failure(let error):
            XCTFail("expected to get success, but got failure with \(error) instead")
        default:
            XCTFail("expected to get success, but got default instead")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case .success(let data):
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case .failure(let error):
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
    
    //MARK: - Helpers
    
    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> (Result<Data, Error>)? {
        let url = feedTestServerURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: (Result<Data, Error>)?
        _ = loader.loadImage(from: url) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> FeedLoadResult? {        
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(client: client, url: feedTestServerURL)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        var expectedResult: FeedLoadResult?
        let exp = expectation(description: "wait for result")
        loader.load { (result) in
            expectedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return expectedResult
    }
    
    private func expectedItem(at index: Int) -> FeedImage {
        FeedImage(id: id(at: index),
                  description: description(at: index),
                  location: location(at: index),
                  image: image(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }

    private func image(at index: Int) -> URL {
        URL(string: "https://url-\(index+1).com")!
    }
    
    private var feedTestServerURL: URL {
        URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }

}
