//
//  Feed.swift
//  Prototype
//
//  Created by Abdul Diallo on 5/31/21.
//

import UIKit

private let reuseIdentifier = "FeedCell"

class FeedViewController: UITableViewController {
    
    private let feedImages: [FeedImageViewModel] = FeedImageViewModel.prototypeFeed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .systemGroupedBackground
        navigationItem.title = "My Feed"
        tableView.register(FeedCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    
}

extension FeedViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? FeedCell else {
            return UITableViewCell()
        }
        cell.configure(with: feedImages[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedImages.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 480
    }
    
}
