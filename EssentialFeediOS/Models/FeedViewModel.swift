//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/15/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation
import iOSFeed

public final class FeedViewModel {
    public typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    
    public var onLoadingStateChange: Observer<Bool>?
    public var onFeedLoad: Observer<[FeedImage]>?
    
    public init(feedLoader: FeedLoader) {
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
