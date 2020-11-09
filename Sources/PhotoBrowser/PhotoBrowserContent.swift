//
//  PhotoBrowserContent.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/4/20.
//

import UIKit

/// Represent content for populating a `PhotoBrowserViewController`
///
/// Default implementations are provided through a protocol extension, so definitions are optional when adopting with one exception.
///
/// - Requires: Either `imagePath` or `image` must be defined to have a valid content object.
public protocol PhotoBrowserContentRepresentable {
    var imageURL: URL? { get }
    var image: UIImage? { get }
    var placeholderImage: UIImage? { get }
}

public extension PhotoBrowserContentRepresentable {
    
    var imagePath: String? {
        return imageURL?.absoluteString
    }
    
    // MARK: - Default Values
    
    /// Must be defined if `image` is not
    var imageURL: URL? {
        return nil
    }
    
    /// Can be defined if you would like a placeholder to be used until the real image can replace it.
    var placeholderImage: UIImage? {
        return image
    }
    
    /// Must be defined if `imagePath` is not
    var image: UIImage? {
        return AsyncImageLoader.imageFromCache(imagePath)
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        Self.validate(imageURL: imageURL, image: image)
    }
    
    static func validate(imageURL: URL?, image: UIImage?) -> Bool {
        return imageURL != nil || image != nil
    }
}

/// An object to use directly if you don't have/need another object adopting `PhotoBrowserContentRepresentable` when using PhotoBrowser
public struct PhotoBrowserContent: PhotoBrowserContentRepresentable {
    public let imageURL: URL?
    public var image: UIImage?
    public let placeholderImage: UIImage?
    
    /// Create an object to provide content to a `PhotoBrowserViewController`
    /// - Throws: Error if neither an `imageURL` nor `image` is provided.
    public init(imageURL: URL? = nil, image: UIImage? = nil, placeholderImage: UIImage? = nil) throws {
        guard Self.validate(imageURL: imageURL, image: image) else {
            throw Err.invalid
        }
        self.imageURL = imageURL
        self.image = image
        self.placeholderImage = placeholderImage
    }
    
    /// Create an object to provide content to a `PhotoBrowserViewController`
    /// - Throws: Error if neither an `imagePath` nor `image` is provided.
    public init(imagePath: String? = nil, image: UIImage? = nil, placeholderImage: UIImage? = nil) throws {
        let imageURL = URL(string: imagePath ?? "")
        try self.init(imageURL: imageURL, image: image, placeholderImage: placeholderImage)
    }
    
    public enum Err: Error {
        case invalid
        
        var localizedDescription: String {
            switch self {
            case .invalid:
                return "Must have a imagePath path or image"
            }
        }
    }
}
