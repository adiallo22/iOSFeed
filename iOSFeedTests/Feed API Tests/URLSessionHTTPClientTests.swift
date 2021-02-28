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
    
    func test_getFromURL_PerformsGetRequestWithURL() {
        URLProtocolStubs.startInterceptingRequest()
        
        let url = URL(string: "url.com")!
        let exp = expectation(description: "Wait for expectation")
        URLProtocolStubs.observeRequest { requests in
            XCTAssertEqual(requests.url, url)
            XCTAssertEqual(requests.httpMethod, "GET")
            exp.fulfill()
        }
        URLSessionHTTPClient().get(url: url) { _ in }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStubs.stopInterceptingRequest()
    }
    
    func test_getURL_failsOnRequestError() {
        URLProtocolStubs.startInterceptingRequest()
        let url = URL(string: "url.com")!
        let error = NSError(domain: "", code: 1, userInfo: nil)
        URLProtocolStubs.stub(data: nil, response: nil, error: error)
        
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
        
        private static var stub: Stub?
        private static var observer: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: NSError?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: NSError?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            self.observer = observer
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStubs.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStubs.self)
            stub = nil
            observer = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            observer?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStubs.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStubs.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStubs.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
    
}
