//
//  URLSessionHTTPVlientTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 2/22/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStubs.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStubs.stopInterceptingRequest()
    }
    
    func test_getFromURL_PerformsGetRequestWithURL() {
        let exp = expectation(description: "Wait for expectation")
        URLProtocolStubs.observeRequest { [weak self] requests in
            XCTAssertEqual(requests.url, self?.anyURL())
            XCTAssertEqual(requests.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: anyURL()) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getfromURL_failsOnRequestError() {
        let expectedError = NSError(domain: "", code: 1, userInfo: nil)
        let receivedError = resultErrorFor(data: nil, response: nil, error: expectedError)
        XCTAssertEqual(expectedError, receivedError as NSError?)
    }
    
    func test_getfromURL_failsOnInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
//        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
//        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
        
    }
    
    func test_getfromURL_suceedOnResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.0, data)
        XCTAssertEqual(receivedValues?.1.statusCode, response.statusCode)
        XCTAssertEqual(receivedValues?.1.url, response.url)
    }
    
    func test_getfromURL_suceedWithEmptyDataOnResponse() {
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.0, emptyData)
        XCTAssertEqual(receivedValues?.1.statusCode, response.statusCode)
        XCTAssertEqual(receivedValues?.1.url, response.url)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-data.com")!
    }
    
    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #file,
                                line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("expected failure but got \(String(describing: response)) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #file,
                                line: UInt = #line) -> (Data, HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .sucess(data, resp):
            return (data, resp)
        default:
            XCTFail("expected success but got \(String(describing: response)) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?,
                           response: URLResponse?,
                           error: Error?,
                           file: StaticString = #file,
                           line: UInt = #line) -> HTTPResponse {

        let sut = makeSUT(file: file, line: line)
        URLProtocolStubs.stub(data: data, response: response, error: error)
        let exp = expectation(description: "wait for expectation")
        
        var receivedResult: HTTPResponse!
        sut.get(from: anyURL()) { (response) in
            receivedResult = response
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedResult
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
