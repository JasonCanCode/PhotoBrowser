//
//  PhotoPageContent.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/4/20.
//

import UIKit

public protocol PhotoPageContentRepresentable {
    var imagePath: String? { get }
    var image: UIImage? { get }
    var placeholderImage: UIImage? { get }
}

public extension PhotoPageContentRepresentable {
    var placeholderImage: UIImage? {
        return image
    }
    
    var image: UIImage? {
        return AsyncImageLoader.imageFromCache(imagePath)
    }
    
    static func validate(imagePath: String?, image: UIImage?) -> Bool {
        if let path = imagePath {
            return URL(string: path) != nil
        } else {
            return image != nil
        }
    }
}

public struct PhotoPageContent: PhotoPageContentRepresentable {
    public let imagePath: String?
    public var image: UIImage?
    public let placeholderImage: UIImage?

    public init?(imagePath: String? = nil, image: UIImage? = nil, placeholderImage: UIImage? = nil) {
        guard Self.validate(imagePath: imagePath, image: image) else {
            assertionFailure("Must have a imagePath path or image")
            return nil
        }
        self.imagePath = imagePath
        self.image = image
        self.placeholderImage = placeholderImage
    }
}
