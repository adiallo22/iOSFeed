//
//  Feed.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public struct Feed: Equatable {
    var id: UUID
    var description: String?
    var location: String?
    var url: URL
}
