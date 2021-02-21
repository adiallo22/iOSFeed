//
//  Feed.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/9/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public struct Feed: Decodable, Equatable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var images: URL
    
    public init(id: UUID, description: String?, location: String?, images: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.images = images
    }
}

struct Root: Decodable {
    var items: [Feed]
}
