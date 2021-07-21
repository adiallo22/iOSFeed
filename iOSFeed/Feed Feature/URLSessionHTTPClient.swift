//
//  URLSessionHTTPClient.swift
//  iOSFeed
//
//  Created by Abdul Diallo on 2/28/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation

struct UnexpectedError: Error { }

public final class URLSessionHTTPClient: HTTPClient {
    
    let session: URLSession
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapper: URLSessionTask

        func cancel() {
            wrapper.cancel()
        }
    }
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                      let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }
        task.resume()
        return URLSessionTaskWrapper(wrapper: task)
    }
    
    public func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) {
        
    }
    
}
