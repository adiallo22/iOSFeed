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
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index],
                                       statusCode: code,
                                       httpVersion: nil,
                                       headerFields: nil)!
        messages[index].completion(.sucess(data, response))
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
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "test", code: 0, userInfo: nil)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliverErrorOnNon200HttpResponse() {
        let (client, sut) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            client.complete(withStatusCode: 400)
        })
    }
    
    func test_load_DeliverErroron200WithInvalidJSON() {
        let (client, sut) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_DeliverEmptyJsonOnSuccess() {
        let (client, sut) = makeSUT()
        var capturedResult = [RemoteFeedLoader.Result]()
        expect(sut, toCompleteWith: .success([]), when: {
            sut.load { capturedResult.append($0) }
            let emptyJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSON)
        })
    }
    
    func test_load_DeliverJsonOnSuccess() {
        let (client, sut) = makeSUT()
        let item1 = Feed(id: UUID(),
                         description: nil,
                         location: nil,
                         images: URL(string: "url.com")!)
        let item1JSON = [
            "id": item1.id.uuidString,
            "images": item1.images.absoluteString
        ]
        let item2 = Feed(id: UUID(),
                         description: "desc",
                         location: "loc",
                         images: URL(string: "url2.com")!)
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "images": item2.images.absoluteString
        ]
        let itemsJSON = ["items": [item1JSON, item2JSON]]
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    //MARK: - Helpers
    
    func makeSUT(url: URL? = URL(string: "https://mockurl1.com/api")) -> (HTTPClientSpy, RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url!)
        return (client, sut)
    }
    
    fileprivate func expect(_ sut: RemoteFeedLoader,
                            toCompleteWith result: RemoteFeedLoader.Result,
                            when action: () -> Void,
                            file: StaticString = #file,
                            line: UInt = #line) {
        var capturedResult = [RemoteFeedLoader.Result]()
        sut.load { capturedResult.append($0) }
        action()
        XCTAssertEqual(capturedResult, [result])
    }

}

