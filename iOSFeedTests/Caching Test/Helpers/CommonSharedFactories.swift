//
//  CommonSharedFactories.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/5/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation
import iOSFeed

func anyFeed() -> FeedImage {
    FeedImage(id: UUID(), description: "", location: "", image: anyURL())
}

func uniqueItems() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feedItems = [anyFeed(), anyFeed()]
    let localFeedItems = feedItems.map {
        LocalFeedImage(id: $0.id,
                      description: $0.description,
                      location: $0.location,
                      image: $0.image)
    }
    return (feedItems, localFeedItems)
}

//MARK: - Date

extension Date {
    private var feedCachedMaxAge: Int {
        7
    }
    func minusFeedChacheMaxAge() -> Date {
        adding(days: feedCachedMaxAge)
    }
    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    func adding(seconds: Int) -> Date {
        self + 1
    }
}
