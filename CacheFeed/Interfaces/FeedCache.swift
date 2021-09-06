//
//  FeedCache.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 8/1/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import iOSFeed

public protocol FeedCache {
    typealias SaveResult = Error?
    func saveOnCache(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
