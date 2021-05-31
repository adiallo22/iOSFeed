//
//  Feed.swift
//  Prototype
//
//  Created by Abdul Diallo on 5/31/21.
//

import UIKit

private let reuseIdentifier = "FeedCell"

class Feed: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FeedCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
}

extension Feed {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? FeedCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
}

class FeedCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
