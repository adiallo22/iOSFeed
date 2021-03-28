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
        store.retrieve { (error) in
            if let retrievedError = error {
                completion(.failure(retrievedError))
            } else {
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
