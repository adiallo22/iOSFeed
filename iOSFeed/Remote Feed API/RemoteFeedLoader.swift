//
//  RemoteFeedLoader.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {    
    
    private let client: HTTPClient
    private let url: URL
    
    public typealias Result = FeedLoadResult
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .sucess(let data, let response):
                do {
                    let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items.toFeed()))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private extension Array where Element == RemoteFeedImage {
    func toFeed() -> [FeedImage] {
        map {
            FeedImage(id: $0.id,
                 description: $0.description,
                 location: $0.location,
                 image: $0.image)
        }
    }
}
