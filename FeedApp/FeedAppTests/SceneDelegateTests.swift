//
//  SceneDelegateTests.swift
//  FeedAppTests
//
//  Created by Abdul Diallo on 8/22/21.
//

import XCTest
import EssentialFeediOS
@testable import FeedApp

class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let sut = SceneDelegate()
        let window = UIWindow()
        
        sut.window = window
        sut.configureWindow()
        
        XCTAssertTrue(window.isKeyWindow, "Expected scene window to be the key window")
        XCTAssertFalse(window.isHidden, "Expected scene window not not be hidden")
    }
    
    func test_configureWindow_configureRootViewController() {
        let sut = SceneDelegate()
        
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topViewController = rootNavigation?.topViewController
        
        XCTAssertTrue(root is UINavigationController, "Expected a UINavigationController")
        XCTAssertTrue(topViewController is FeedViewController, "Expected the top view controller to be of type FeedViewController")
    }
    
}
