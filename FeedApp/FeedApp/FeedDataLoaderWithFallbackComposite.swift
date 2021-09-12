//
//  FeedDataLoaderWithFallbackComposite.swift
//  FeedApp
//
//  Created by Abdul Diallo on 7/25/21.
//

import Foundation
import iOSFeed

public final class FeedDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryDataLoader: FeedImageDataLoader
    private let fallbackDataLoader: FeedImageDataLoader
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primaryDataLoader = primary
        self.fallbackDataLoader = fallback
    }
    
    public func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primaryDataLoader.loadImage(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                task.wrapped = self?.fallbackDataLoader.loadImage(from: url, completion)
            }
        }
        return task
    }
    
}
