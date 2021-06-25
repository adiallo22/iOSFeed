//
//  FeedViewControllerTests+Helper.swift
//  EssentialFeediOSTests
//
//  Created by Abdul Diallo on 6/21/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import XCTest
import UIKit
import iOSFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
