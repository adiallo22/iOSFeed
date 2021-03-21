//
//  RemoteFeedItem.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 3/17/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

struct RemoteFeedItem: Decodable, Equatable {
    var id: UUID
    var description: String?
    var location: String?
    var image: URL
    
    init(id: UUID, description: String?, location: String?, image: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.image = image
    }
}
