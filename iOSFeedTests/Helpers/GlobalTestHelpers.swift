//
//  GlobalTestHelpers.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/5/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://anyurl.com")!
}

func anyError() -> Error {
    NSError(domain: "any error", code: 0, userInfo: nil)
}
