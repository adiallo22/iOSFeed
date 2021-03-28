//
//  LoadFeedFromCacheUseCaseTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 3/28/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_requestCacheRetrievalFailsWithError() {
        let (store, sut) = makeSUT()
        let retreivedError = anyError()
        
        let exp = expectation(description: "wait for result")
        var receivedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
                exp.fulfill()
            default:
                XCTFail("expected to get \(retreivedError) but got success instead")
            }
        }
        
        store.completeRetrieval(with: retreivedError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, retreivedError as NSError?)
    }
    
    func test_load_deliversNoFeedOnEmptyCache() {
        let (store, sut) = makeSUT()

        let exp = expectation(description: "wait for result")
        var receievdImages: [FeedImage]?
        sut.load { result in
            switch result {
            case .success(let images):
                receievdImages = images
                exp.fulfill()
            case .failure:
                XCTFail("expected to get success, but got failure instead")
            }
        }

        store.completeRetrievalSuccessfully()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receievdImages, [])
    }

}

//MARK: - Helpers

extension LoadFeedFromCacheUseCaseTests {
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file,
                 line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoad) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoad(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }
    
    func anyError() -> Error {
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
}
