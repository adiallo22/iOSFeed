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
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void)
}
