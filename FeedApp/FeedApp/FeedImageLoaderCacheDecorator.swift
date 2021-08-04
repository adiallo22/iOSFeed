//
//  FeedImageLoaderCacheDecorator.swift
//  FeedApp
//
//  Created by Abdul Diallo on 8/3/21.
//

import iOSFeed

public final class FeedImageLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        decoratee.loadImage(from: url) { [weak self] result in
            completion(result.map({ data in
                self?.cache.saveIgnoringCompletion(data, for: url)
                return data
            }))
        }
    }
}

private extension FeedImageDataCache {
    func saveIgnoringCompletion(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
