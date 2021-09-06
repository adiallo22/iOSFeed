//
//  FeedImageDataCache.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 8/3/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
