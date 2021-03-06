//
//  FeedLoaderCacheDecorator.swift
//  FeedApp
//
//  Created by Abdul Diallo on 8/2/21.
//

import iOSFeed
import CacheFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        decoratee.load { [weak self] result in
            switch result {
            case .success(let feed): self?.cache.saveIgnoringCompletion(feed)
            case .failure: break
            }
            completion(result)
        }
    }
}

private extension FeedCache {
    func saveIgnoringCompletion(_ feed: [FeedImage]) {
        saveOnCache(feed) { _ in }
    }
}
