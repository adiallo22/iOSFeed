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
    
    private var messages = [(url: URL, completion: (HTTPResponse) -> Void)]()
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) {
        messages.append((url, completion))
    }
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    func complete(withStatusCode code: Int, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index],
                                       statusCode: code,
                                       httpVersion: nil,
                                       headerFields: nil)!
        messages[index].completion(.sucess(response))
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (client, _) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_doesRequestDataFromURL() {
        let mockURL = URL(string: "https://mockurl2.com/api")
        let (client, sut) = makeSUT(url: mockURL)
        sut.load { _ in }
        XCTAssertEqual(mockURL, client.requestedURLs.first)
    }
    
    func test_loadTwice_doesRequestDataFromURLTwice() {
        let mockURL = URL(string: "https://mockurl2.com/api")
        let (client, sut) = makeSUT(url: mockURL)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [mockURL, mockURL])
    }
    
    func test_load_deliverErrorOnClientError() {
        let (client, sut) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        sut.load { capturedError.append($0) }
        client.complete(with: clientError)
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliverErrorOnNon200HttpResponse() {
        let (client, sut) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        client.complete(withStatusCode: 400)
        XCTAssertEqual(capturedError, [.invalidData])
    }
    
    func makeSUT(url: URL? = URL(string: "https://mockurl1.com/api")) -> (HTTPClientSpy, RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url!)
        return (client, sut)
    }

}

