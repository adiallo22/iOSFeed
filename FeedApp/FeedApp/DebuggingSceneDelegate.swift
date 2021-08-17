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
            print("debug: reset is called")
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)

    }
    
    override func makeRemoteClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            print("debug: connectivity \(connectivity)")
            return DebuggingHTTPClient(connectivity: connectivity)
        }
        print("debug: connectivity remote client")
        return super.makeRemoteClient()
    }
    
}

private final class DebuggingHTTPClient: HTTPClient {
    private let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) -> HTTPClientTask {
        switch connectivity {
        case "online": completion(.success(makeSuccessfulResponse(for: url)))
            
        default: completion(.failure(NSError(domain: "any error", code: 0)))
        }
        return Task()
    }
    
    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com": return makeImageData()
            
        default: return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!.pngData()!
    }

    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}
#endif
