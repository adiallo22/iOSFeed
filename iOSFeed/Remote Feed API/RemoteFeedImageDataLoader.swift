//
//  RemoteFeedImageDataLoader.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 7/5/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
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
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success((let data, let response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case .failure(let error): task.complete(with: .failure(error))
            }
        })
        return task
    }
    
}
