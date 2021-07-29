//
//  XCTestCase+Expect.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/28/21.
//

import XCTest
import iOSFeed

protocol FeedLoaderTestCase: XCTestCase { }

extension FeedLoaderTestCase {
    
    func expect(_ sut: FeedLoader,
                toCompleteWith expectedResult: FeedLoadResult,
                file: StaticString = #file,
                line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
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
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
