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
        let (item1, item1JSON) = makeItem(id: UUID(), images: URL(string: "url.com")!)
         let (item2, item2JSON) = makeItem(id: UUID(), description: "", location: "", images: URL(string: "url.com")!)
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            let json = makeItemJSon([item1JSON, item2JSON])
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
    
    fileprivate func makeItem(id: UUID, description: String? = nil, location: String? = nil, images: URL) -> (Feed, [String: Any]) {
        let item = Feed(id: id, description: description, location: location, images: images)
        let itemJSON = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "images": images.absoluteString
            ].reduce(into: [String: Any]()) { (acc, e) in
                if let value = e.value { acc[e.key] = value }
        }
        return (item, itemJSON)
    }
    
    fileprivate func makeItemJSon(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }

}

