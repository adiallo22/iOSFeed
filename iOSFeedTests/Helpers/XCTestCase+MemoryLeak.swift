//
//  XCTestCase+MemoryLeak.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 2/28/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance is supposed to be deallocated but is retained instead", file: file, line: line)
        }
    }
    
}
