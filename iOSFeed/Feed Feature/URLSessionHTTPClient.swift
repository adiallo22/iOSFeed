//
//  URLSessionHTTPClient.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/28/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

struct UnexpectedError: Error { }

public class URLSessionHTTPClient: HTTPClient {
    
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                let response = response as? HTTPURLResponse {
                completion(.sucess(data, response))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }.resume()
    }
    
}
