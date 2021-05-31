//
//  FeedCell.swift
//  Prototype
//
//  Created by Abdul Diallo on 5/31/21.
//

import UIKit
import SnapKit

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
        label.textColor = .lightGray
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
        label.textColor = .lightGray
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
            $0.edges.equalToSuperview().inset(12)
        }
    }
    
}

extension FeedCell {
    func configure(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        
        feedImage.image = UIImage(named: model.imageName)
    }
}
