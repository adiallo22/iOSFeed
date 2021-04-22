//
//  CodableFeedStore.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 4/20/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    
    var storeURL: URL
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map {
                $0.local
            }
        }
    }
    
    private struct CodableFeedImage: Codable {
        var id: UUID
        var description: String?
        var location: String?
        var image: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.image = image.image
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, image: image)
        }
    }
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        do {
            let decoder = JSONDecoder()
            let decodedCache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: decodedCache.localFeed, timestamp: decodedCache.timestamp))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = items.map(CodableFeedImage.init)
            let encodedCache = try encoder.encode(Cache(feed: cache, timestamp: timestamp))
            try encodedCache.write(to: storeURL)
        } catch let error {
            completion(error)
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            completion(nil)
            return
        }
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }

}
