//
//  URLSessionHTTPVlientTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 2/22/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed
import Remote_Feed_API

class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStubs.removeStub()
    }
    
    func test_getFromURL_PerformsGetRequestWithURL() {
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    func test_getfromURL_failsOnInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyError())))
    }
    
    func test_getfromURL_suceedOnResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor((data: data, response: response, error: nil))
        
        XCTAssertEqual(receivedValues?.0, data)
        XCTAssertEqual(receivedValues?.1.statusCode, response.statusCode)
        XCTAssertEqual(receivedValues?.1.url, response.url)
    }
    
    func test_getfromURL_suceedWithEmptyDataOnResponse() {
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        
        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))
        
        XCTAssertEqual(receivedValues?.0, emptyData)
        XCTAssertEqual(receivedValues?.1.statusCode, response.statusCode)
        XCTAssertEqual(receivedValues?.1.url, response.url)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        let task = makeSUT().get(from: url) { result in
            switch result {
            case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
                break
                
            default:
                XCTFail("Expected cancelled result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        task.cancel()
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStubs.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(_ values: (data: Data?,
                                           response: URLResponse?,
                                           error: Error?)? = nil,
                                taskHandler: (HTTPClientTask) -> Void = { _ in },
                                file: StaticString = #file,
                                line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("expected failure but got \(String(describing: result)) instead",
                    file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(_ values: (data: Data?,
                                            response: URLResponse?,
                                            error: Error?),
                                 file: StaticString = #file,
                                 line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)
        switch result {
        case let .success((data, resp)):
            return (data, resp)
        default:
            XCTFail("expected success but got \(String(describing: result)) instead",
                    file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(_ values: (data: Data?,
                                      response: URLResponse?,
                                      error: Error?)?,
                           taskHandler: (HTTPClientTask) -> Void = { _ in },
                           file: StaticString = #file,
                           line: UInt = #line) -> HTTPResponse {
        values.map { URLProtocolStubs.stub(data: $0, response: $1, error: $2) }
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for expectation")
        
        var receivedResult: HTTPResponse!
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func nonHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
}
