//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Abdul Diallo on 6/16/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

import Foundation
import iOSFeed

public final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    // MARK: - Variables
    var description: String? { model.description }
    
    var location: String?  { model.location }
    
    var hasLocation: Bool { location != nil }
    
    var image: URL { model.image }
    
    // MARK: - Observers
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onshouldRetryImageLoadStateChange: Observer<Bool>?

    public init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onshouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImage(from: model.image) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func handle(_ result: Result<Data, Error>) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onshouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
