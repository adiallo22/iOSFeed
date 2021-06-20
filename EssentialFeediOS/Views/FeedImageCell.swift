//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/6/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import UIKit
import SnapKit

public class FeedImageCell: UITableViewCell {
    
    var onRetry: (() -> Void)?

    private let pinImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "pin.fill"))
        view.snp.makeConstraints {
            $0.height.equalTo(12)
            $0.width.equalTo(12)
        }
        view.contentMode = .scaleAspectFill
        return view
    }()

    public let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    public lazy var locationContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pinImage, locationLabel])
        stack.spacing = 6
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    
    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
        
    public let feedImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.snp.makeConstraints {
            $0.height.equalTo(400).priority(.high)
        }
        view.layer.cornerRadius = 10
        return view
    }()
    
    public lazy var feedImageContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [locationContainer, feedImageView, descriptionLabel])
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func layout() {
        selectionStyle = .none
        contentView.addSubview(feedImageContainer)
        feedImageContainer.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        contentView.addSubview(feedImageRetryButton)
        feedImageRetryButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
        
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
