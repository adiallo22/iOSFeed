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
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let localStoreURL = NSPersistentContainer
                                .defaultDirectoryURL()
                                .appendingPathComponent("FeedStore")
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL, bundle: bundle)
        return localStore
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5d1c78f21e661a0001ce7cfd/1562147059075/feed-case-study-v1-api-feed.json")!
        
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let remoteFeedLoader = RemoteFeedLoader(client: httpClient, url: url)
        
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallBack: remoteFeedLoader),
            imageLoader: FeedDataLoaderWithFallbackComposite(
                primary: FeedImageLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader),
                fallback: remoteImageLoader)
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
    }
    
    func makeRemoteClient() -> HTTPClient { httpClient }

}
