//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/13/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    
    private (set) lazy var view = binded(UIRefreshControl())
        
    private let viewModel: FeedViewModel
    
    public init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] loadingState in
            loadingState ? view?.beginRefreshing()  : view?.endRefreshing()
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }

}
