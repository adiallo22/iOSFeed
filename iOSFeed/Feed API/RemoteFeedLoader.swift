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
    
    public typealias Result = FeedLoadResult<Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(_ completion: @escaping (FeedLoadResult<Error>) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .sucess(let data, let response):
                completion(FeedItemsMapper.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
