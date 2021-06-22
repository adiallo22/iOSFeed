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
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedController.title = "My Feed"
        
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
