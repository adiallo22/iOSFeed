//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/15/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation
import iOSFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
