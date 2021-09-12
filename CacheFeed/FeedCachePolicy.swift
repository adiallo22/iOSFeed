//
//  FeedCachePolicy.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 4/5/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

final class FeedCachePolicy {
    
    private init() { }
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxDaysAllowedForCache: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxedAged = calendar.date(byAdding: .day,
                                            value: maxDaysAllowedForCache,
                                            to: timestamp) else {
            return false
        }
        return date < maxedAged
    }
    
}
