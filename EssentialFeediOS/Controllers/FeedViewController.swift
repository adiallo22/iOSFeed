//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 5/31/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit
import iOSFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var refreshController: FeedRefreshViewController?
    private weak var imageLoader: FeedImageDataLoader?
    
    private var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController?.view
        
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed.map {
                FeedImageCellController(model: $0, imageLoader: self!.imageLoader!)
            }
        }
        
        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }
    
    private func cellForRow(at indexPath: IndexPath) -> FeedImageCellController {
        tableModel[indexPath.row]
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellForRow(at: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellForRow(at: indexPath).preLoad()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellForRow(at: indexPath).cancelLoad()
    }
    
}
