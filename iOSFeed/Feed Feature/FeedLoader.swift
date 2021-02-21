//
//  FeedLoader.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public typealias FeedLoadResult = Result<[Feed], Error>

protocol FeedLoader {
    func load(_ completion: @escaping (FeedLoadResult) -> Void)
}
