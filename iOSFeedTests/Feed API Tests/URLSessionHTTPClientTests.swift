//
//  URLSessionHTTPVlientTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 2/22/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class URLSessionHTTPClient {
    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    func get(url: URL, completion: @escaping (HTTPResponse) -> Void) {
        session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getURL_failsOnRequestError() {
        URLProtocolStubs.startInterceptingRequest()
        let url = URL(string: "url.com")!
        let error = NSError(domain: "", code: 1, userInfo: nil)
        URLProtocolStubs.stub(url: url, data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for expectation")
        sut.get(url: url) { (response) in
            switch response {
            case .sucess(_, _):
                XCTFail("expected error with error \(error) but got \(response) instead")
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError, error)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStubs.stopInterceptingRequest()
    }
    
    //MARK: - Helpers
    
    private class URLProtocolStubs: URLProtocol {
        
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: NSError?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: NSError?) {
            stubs = [url: Stub(data: data, response: response, error: error)]
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStubs.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStubs.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStubs.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStubs.stubs[url] else { return }
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
    
}
