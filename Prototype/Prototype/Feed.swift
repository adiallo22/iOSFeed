//
//  Feed.swift
//  Prototype
//
//  Created by Abdul Diallo on 5/31/21.
//

import UIKit
import SnapKit

private let reuseIdentifier = "FeedCell"

class Feed: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FeedCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 580
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
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
    
    private let pinImage: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "pin"))
        view.snp.makeConstraints {
            $0.height.equalTo(12)
            $0.width.equalTo(12)
        }
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "test1"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var locationContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pinImage, locationLabel])
        stack.spacing = 6
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    
    private let feedImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "test1test1test1test1test1test1test1test1test1test1test1"
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [locationContainer, feedImage, descriptionLabel])
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func layout() {
        selectionStyle = .none
        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
    }
    
}
