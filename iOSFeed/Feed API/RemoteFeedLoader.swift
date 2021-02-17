//
//  RemoteFeedLoader.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public enum HTTPResponse {
    case sucess(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void)
}

public final class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result  in
            switch result {
            case .sucess:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
