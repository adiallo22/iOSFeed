//
//  RemoteFeedImageDataLoaderTests.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 7/4/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import iOSFeed

 class RemoteFeedImageDataLoader {
     init(client: Any) {

     }
 }

 class RemoteFeedImageDataLoaderTests: XCTestCase {

     func test_init_doesNotPerformAnyURLRequest() {
         let (_, client) = makeSUT()

         XCTAssertTrue(client.requestedURLs.isEmpty)
     }

     private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
         let client = HTTPClientSpy()
         let sut = RemoteFeedImageDataLoader(client: client)
         trackForMemoryLeaks(sut, file: file, line: line)
         trackForMemoryLeaks(client, file: file, line: line)
         return (sut, client)
     }

     private class HTTPClientSpy {
         var requestedURLs = [URL]()
     }
    
 }
