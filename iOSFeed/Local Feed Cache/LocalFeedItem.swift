//
//  LocalFeedItem.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 3/17/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

public struct LocalFeedImage: Codable, Equatable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var image: URL
    
    public init(id: UUID, description: String?, location: String?, image: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.image = image
    }
}
