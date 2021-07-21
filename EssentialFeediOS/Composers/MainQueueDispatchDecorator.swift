//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/22/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation
import iOSFeed

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    func dispatch(_ completion: @escaping () -> Void) {
            Thread.isMainThread
                ? completion()
                : DispatchQueue.main.async { completion() }
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        decoratee.load { [weak self] (result) in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImage(from url: URL, _ completion: @escaping FeedImageDataLoaderResult) -> FeedImageDataLoaderTask {
        decoratee.loadImage(from: url) { [weak self] (result) in
            self?.dispatch { completion(result) }
        }
    }
}
