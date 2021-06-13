//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/13/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit
import iOSFeed

final class FeedImageCellController {
    
    private var task: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = (model.location == nil)
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImage(from: self.model.image) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
                
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    func preLoad() {
        task = imageLoader.loadImage(from: self.model.image) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
    
}
