//
//  HTTPClientSpy.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 7/5/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import iOSFeed
import Remote_Feed_API

final class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPResponse) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    var requestedURLs: [URL] { messages.map { $0.url } }
    
    private struct Task: HTTPClientTask {
        var callBack: () -> Void
        func cancel() { callBack() }
    }
    
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}
