//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/13/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit
import iOSFeed

public final class FeedUIComposer {
    
    private init() { }
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        
        let title = NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedUIComposer.self),
                          comment: "title for feed screen")
        
        let feedController = FeedUIComposer.makeFeedViewController(feedViewModel: feedViewModel,
                                                                   with: title)
        
        feedViewModel.onFeedLoad = FeedUIComposer.adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController,
                                                   loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map {
                let feedImageViewModel = FeedImageViewModel(model: $0,
                                                            imageLoader: loader,
                                                            imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel: feedImageViewModel)
            }
        }
    }
    
}

extension FeedUIComposer {
    static func makeFeedViewController(feedViewModel: FeedViewModel, with title: String) -> FeedViewController {
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedController.title = title
        return feedController
    }
}

private final class MainQueueDispatchDecorator: FeedLoader {
    private let decoratee: FeedLoader
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        decoratee.load { (result) in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
