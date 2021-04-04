//
//  LocalFeedLoad.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 3/15/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

final public class LocalFeedLoad {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    private var maxDaysAllowedForCache: Int {
        return 7
    }
    
    public typealias SaveResult = Error?
    public typealias LocalResult = (FeedLoadResult) -> Void
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
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
    
    public func load(_ completion: @escaping LocalResult) {
        store.retrieve { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.store.deleteCacheFeed { _ in }
                completion(.failure(error))
            case .found(feed: let feed, timestamp: let timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
            case .empty:
                completion(.success([]))
            case .found:
                self.store.deleteCacheFeed { _ in }
                completion(.success([]))
            }
        }
    }
    
    private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxedAged = calendar.date(byAdding: .day,
                                            value: maxDaysAllowedForCache,
                                            to: timestamp) else { //add 7 days to the current calendar retrieved
            return false
        }
        return currentDate() < maxedAged //return true if current date is max age allow     &   false if current date is more than max allow
    }
}

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
