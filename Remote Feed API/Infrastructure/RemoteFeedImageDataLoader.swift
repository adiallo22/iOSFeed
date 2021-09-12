//
//  RemoteFeedImageDataLoader.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 7/5/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation
import iOSFeed

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((Result<Data, Swift.Error>) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (Result<Data, Swift.Error>) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: (Result<Data, Swift.Error>)) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                            .mapError { _ in Error.connectivity }
                            .flatMap { (data, response) in
                                let isValidResponse = !data.isEmpty && response.statusCode == 200
                                return isValidResponse ? .success(data) : .failure(Error.invalidData)
                            })
        })
        return task
    }
    
}
