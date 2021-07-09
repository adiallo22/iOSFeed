//
//  FeedImageDataStore.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 7/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
