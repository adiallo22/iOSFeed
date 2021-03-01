//
//  URLSessionHTTPVlientTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 2/22/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

struct UnexpectedError: Error { }

class URLSessionHTTPClient {
    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    func get(url: URL, completion: @escaping (HTTPResponse) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                data.count > 0,
                let response = response as? HTTPURLResponse {
                completion(.sucess(data, response))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_PerformsGetRequestWithURL() {
        URLProtocolStubs.startInterceptingRequest()

        let exp = expectation(description: "Wait for expectation")
        URLProtocolStubs.observeRequest { [weak self] requests in
            XCTAssertEqual(requests.url, self?.anyURL())
            XCTAssertEqual(requests.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(url: anyURL()) { _ in }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStubs.stopInterceptingRequest()
    }
    
    func test_getfromURL_failsOnRequestError() {
        let expectedError = NSError(domain: "", code: 1, userInfo: nil)
        let receivedError = resultErrorFor(data: nil, response: nil, error: expectedError)
        XCTAssertEqual(expectedError, receivedError as NSError?)
    }
    
    func test_getfromURL_failsOnInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
//        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
        
    }
    
    func test_getfromURL_suceedOnResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        URLProtocolStubs.stub(data: data, response: response, error: nil)
        
        let exp = expectation(description: "wait for completion")
        
        makeSUT().get(url: anyURL()) { (result) in
            switch result {
            case let .sucess(receivedData, receivedResponse):
//                XCTAssertEqual(receivedData, data)
//                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            default:
                XCTFail("expected success but got \(response) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        URL(string: "http://helloworld.com")!
    }
    
    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #file,
                                line: UInt = #line) -> Error? {
        URLProtocolStubs.startInterceptingRequest()

        let sut = makeSUT(file: file, line: line)
        URLProtocolStubs.stub(data: data, response: response, error: error)
                
        let exp = expectation(description: "wait for expectation")
        var receivedError: Error?
        sut.get(url: anyURL()) { (response) in
            switch response {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("expected failure but got \(response) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStubs.stopInterceptingRequest()
        return receivedError
    }
    
    private func anyData() -> Data {
        Data(bytes: "any data".utf8)
    }
    
    private func anyError() -> Error {
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    private func nonHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private class URLProtocolStubs: URLProtocol {
        
        private static var stub: Stub?
        private static var observer: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
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
