//
//  URLSessionHTTPVlientTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 2/22/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: HTTPSession
    init(session: HTTPSession) {
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
    
    func test_getURL_resumeDataTaskWithUrl() {
        let url = URL(string: "url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(url: url) { (_) in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
        
    }
    
    func test_getURL_failsOnRequestError() {
        let url = URL(string: "url.com")!
        let error = NSError(domain: "", code: 1, userInfo: nil)
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for expectation")
        sut.get(url: url) { (response) in
            switch response {
            case .sucess(_, _):
                XCTFail("expected error with error \(error) but got \(response) instead")
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private class URLSessionSpy: HTTPSession {
        
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: NSError?
        }
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: NSError? = nil) {
            stubs = [url: Stub(task: task, error: error)]
        }
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("couldnt find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() { }
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0
        func resume() {
            resumeCallCount += 1
        }
    }
    
}
