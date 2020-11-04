//
//  PhotoPageContent.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/4/20.
//

import UIKit

public protocol PhotoPageContentRepresentable {
    var imagePath: String { get }
    var placeholderImage: UIImage? { get }
}

public extension PhotoPageContentRepresentable {
    var placeholderImage: UIImage? {
        return nil
    }
}

public struct PhotoPageContent: PhotoPageContentRepresentable {
    public let imagePath: String
    public let placeholderImage: UIImage?

    public init(imagePath: String, placeholderImage: UIImage? = nil) {
        self.imagePath = imagePath
        self.placeholderImage = placeholderImage
    }
}
