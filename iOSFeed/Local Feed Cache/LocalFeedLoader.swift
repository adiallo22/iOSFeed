//
//  LocalFeedLoad.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 3/15/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

final public class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
        
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
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
            case .found(feed: let feed, timestamp: let timestamp)
                    where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
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
            case .found(feed: _, timestamp: let timestamp)
                    where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
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
