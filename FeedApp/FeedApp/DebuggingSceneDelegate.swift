//
//  DebuggingSceneDelegate.swift
//  FeedApp
//
//  Created by Abdul Diallo on 8/8/21.
//

import UIKit
import EssentialFeediOS
import iOSFeed
import CoreData

#if DEBUG
class DebuggingSceneDelegate: SceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)

    }
    
    override func makeRemoteClient() -> HTTPClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        return super.makeRemoteClient()
    }
    
}

private final class AlwaysFailingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "any error", code: 0)))
        return Task()
    }
}
#endif
