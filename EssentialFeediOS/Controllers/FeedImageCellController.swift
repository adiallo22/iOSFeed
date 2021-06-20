//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/13/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit

final class FeedImageCellController {
    private var viewModel: FeedImageViewModel<UIImage>
    private var cell: FeedImageCell?
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> FeedImageCell {
        cell = tableView.dequeueReusableCell()
        configureCell()
        viewModel.loadImageData()
        return cell!
    }
    
    func preLoad() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        viewModel.cancelImageDataLoad()
    }
    
    private func configureCell() {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = viewModel.loadImageData
        cell?.feedImageView.animateImageShowing(try? viewModel.image.convertToUIIMage())
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onshouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
    
}
