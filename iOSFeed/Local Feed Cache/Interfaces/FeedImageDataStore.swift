//
//  FeedImageDataStore.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 7/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public protocol FeedImageDataStore {
    typealias InsertionResult = Swift.Result<Void, Error>
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)

    typealias RetrieveResult = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (RetrieveResult) -> Void)
}
