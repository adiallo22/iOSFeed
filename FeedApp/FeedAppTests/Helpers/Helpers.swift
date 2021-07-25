//
//  Helpers.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/25/21.
//

import iOSFeed
import XCTest

func uniqueItems() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", image: URL(string: "any-url.com")!)]
}

func anyError() -> Error {
    NSError(domain: "any error", code: 0, userInfo: nil)
}

func anyURL() -> URL {
    URL(string: "http://anyurl.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance is supposed to be deallocated but is retained instead", file: file, line: line)
        }
    }
}
