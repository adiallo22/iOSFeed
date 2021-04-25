//
//  HttpClient.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/18/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

public enum HTTPResponse {
    case sucess(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    ///The completion handler can be invoked in any thread
    ///Client is responsible to dispatch to the appropriate thread if neccessasry
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void)
}
