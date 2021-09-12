//
//  XCTestCase+FeedImageDataLoader.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 8/3/21.
//

import iOSFeed
import XCTest

protocol FeedDataLoaderTestCase: XCTestCase { }

extension FeedDataLoaderTestCase {
    
    func expect(_ sut: FeedImageDataLoader,
                        toCompleteWith expectedResult: Result<Data, Error>,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImage(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
