//
//  AsyncImageView.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

open class AsyncImageView: UIImageView {
    public private(set) var urlString: String?

    public func updateImage(fromURLString urlString: String, placeholderImage: UIImage? = nil) {
        let placeholderImage = placeholderImage ?? self.image
        self.urlString = urlString

        AsyncImageLoader.updateImage(fromURLString: urlString, placeholderImage: placeholderImage) { [weak self] newImage, _ in
            if let newImage = newImage {
                // Use the most recently cached image of the stored urlString if available to avoid an issue with dequeued cells
                self?.image = AsyncImageLoader.imageFromCache(self?.urlString) ?? newImage
            }
        }
    }
}
