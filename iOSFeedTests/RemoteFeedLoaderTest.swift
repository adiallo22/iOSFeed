//
//  iOSFeedTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 2/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class HTTPClientSpy: HTTPClient {
    var requestURLs = [URL]()
    func get(from url: URL) {
        requestURLs.append(url)
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (client, _) = makeSUT()
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_doesRequestDataFromURL() {
        let mockURL = URL(string: "https://mockurl2.com/api")
        let (client, sut) = makeSUT(url: mockURL)
        sut.load()
        XCTAssertEqual(mockURL, client.requestURLs.first)
    }
    
    func test_loadTwice_doesRequestDataFromURLTwice() {
        let mockURL = URL(string: "https://mockurl2.com/api")
        let (client, sut) = makeSUT(url: mockURL)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestURLs, [mockURL, mockURL])
    }
    
    func makeSUT(url: URL? = URL(string: "https://mockurl1.com/api")) -> (HTTPClientSpy, RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url!)
        return (client, sut)
    }

}

