//
//  FeedLoaderWithFallbackComposite.swift
//  FeedApp
//
//  Created by Abdul Diallo on 7/25/21.
//

import Foundation
import iOSFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    
    let primary: FeedLoader
    let fallBack: FeedLoader
    
    public init(primary: FeedLoader, fallBack: FeedLoader) {
        self.primary = primary
        self.fallBack = fallBack
    }
    
    public func load(_ completion: @escaping (FeedLoadResult) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallBack.load(completion)
            }
        }
    }
    
}
