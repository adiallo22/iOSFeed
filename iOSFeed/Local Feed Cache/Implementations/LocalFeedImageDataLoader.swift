//
//  LocalFeedImageDataLoader.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 7/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public typealias ImageDataLoaderRESULT = Result<Data, Swift.Error>

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
}

// MARK: - loadImage

extension LocalFeedImageDataLoader {
    
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((ImageDataLoaderRESULT) -> Void)?

            init(_ completion: @escaping (ImageDataLoaderRESULT) -> Void) {
                self.completion = completion
            }

            func complete(with result: ImageDataLoaderRESULT) {
                completion?(result)
            }

            func cancel() {
                preventFurtherCompletions()
            }

            private func preventFurtherCompletions() {
                completion = nil
            }
        }
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                            .mapError { _ in LoadError.failed }
                            .flatMap { data in data.map { .success($0) } ?? .failure(LoadError.notFound) })
        }
        return task
    }
    
}

// MARK: - save

extension LocalFeedImageDataLoader {
    
    public typealias SaveResult = Result<Void, Swift.Error>
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { result in
            completion(result.mapError { _ in SaveError.failed })
        }
    }
    
}
