//
//  FeedLoaderStubs.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 7/28/21.
//

import iOSFeed

class FeedLoaderStub: FeedLoader {
    var result: FeedLoadResult
    
    init(result: FeedLoadResult) {
        self.result = result
    }
    
    func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        completion(result)
    }
}
