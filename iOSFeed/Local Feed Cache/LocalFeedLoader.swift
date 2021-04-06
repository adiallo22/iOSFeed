//
//  LocalFeedLoad.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 3/15/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

final class FeedCachePolicy {
    
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    private var maxDaysAllowedForCache: Int {
        return 7
    }
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    func validate(_ timestamp: Date) -> Bool {
        guard let maxedAged = calendar.date(byAdding: .day,
                                            value: maxDaysAllowedForCache,
                                            to: timestamp) else {
            return false
        }
        return currentDate() < maxedAged
    }
}

final public class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    private let cachePolicy: FeedCachePolicy
        
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = FeedCachePolicy(currentDate: currentDate)
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LocalResult = (FeedLoadResult) -> Void
    public func load(_ completion: @escaping LocalResult) {
        store.retrieve { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .found(feed: let feed, timestamp: let timestamp) where self.cachePolicy.validate(timestamp):
                completion(.success(feed.toModels()))
            case .empty:
                completion(.success([]))
            case .found:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    public func saveOnCache(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let deletionError = error {
                completion(deletionError)
            } else {
                self.cache(feeds, with: completion)
            }
        }
    }
    private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {

    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCacheFeed { (_) in }
            case .found(feed: _, timestamp: let timestamp) where !self.cachePolicy.validate(timestamp):
                self.store.deleteCacheFeed { (_) in }
            case .empty, .found: break
            }
        }
    }
}

//MARK: - Array Extensions

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.description,
                image: $0.image
            )
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map {
            FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.description,
                image: $0.image
            )
        }
    }
}
