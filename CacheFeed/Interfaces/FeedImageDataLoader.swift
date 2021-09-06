//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/13/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public typealias FeedImageDataLoaderResult = (Result<Data, Error>) -> Void

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader: AnyObject {
    func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask
}
