//
//  SceneDelegate.swift
//  FeedApp
//
//  Created by Abdul Diallo on 7/20/21.
//

import UIKit
import EssentialFeediOS
import iOSFeed
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let localStoreURL = NSPersistentContainer
                            .defaultDirectoryURL()
                            .appendingPathComponent("FeedStore")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5d1c78f21e661a0001ce7cfd/1562147059075/feed-case-study-v1-api-feed.json")!
        
        let remoteClient = makeRemoteClient()
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        let remoteFeedLoader = RemoteFeedLoader(client: remoteClient, url: url)
                
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
//        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
//        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
//        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
//
//        let _ = FeedUIComposer.feedComposedWith(
//            feedLoader: FeedLoaderWithFallbackComposite(
//                primary: FeedLoaderCacheDecorator(
//                    decoratee: remoteFeedLoader,
//                    cache: localFeedLoader),
//                fallBack: remoteFeedLoader),
//            imageLoader: FeedDataLoaderWithFallbackComposite(
//                primary: FeedImageLoaderCacheDecorator(
//                    decoratee: remoteImageLoader,
//                    cache: localImageLoader),
//                fallback: remoteImageLoader)
//        )
        
        let backupfeedVC = FeedUIComposer.feedComposedWith(feedLoader: remoteFeedLoader, imageLoader: remoteImageLoader)
        
        window?.rootViewController = backupfeedVC
    }
    
    func makeRemoteClient() -> HTTPClient {
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }

}
