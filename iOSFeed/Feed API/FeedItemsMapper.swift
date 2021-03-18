//
//  FeedItemsMapper.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/18/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

class FeedItemsMapper {
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
    
}

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
