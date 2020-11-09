//
//  PhotoPageContent.swift
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
    var imagePath: String? { get }
    var image: UIImage? { get }
    var placeholderImage: UIImage? { get }
}

public extension PhotoBrowserContentRepresentable {
    
    /// Must be defined if `image` is not
    var imagePath: String? {
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
        Self.validate(imagePath: imagePath, image: image)
    }
    
    static func validate(imagePath: String?, image: UIImage?) -> Bool {
        if let path = imagePath {
            return URL(string: path) != nil
        } else {
            return image != nil
        }
    }
}

/// An object to use directly if you don't have/need another object adopting `PhotoBrowserContentRepresentable` when using PhotoBrowser
public struct PhotoPageContent: PhotoBrowserContentRepresentable {
    public let imagePath: String?
    public var image: UIImage?
    public let placeholderImage: UIImage?
    
    /// Create an object to provide content to a `PhotoBrowserViewController`
    /// - Throws: Error if neither an `imagePath` nor `image` is provided.
    public init(imagePath: String? = nil, image: UIImage? = nil, placeholderImage: UIImage? = nil) throws {
        guard Self.validate(imagePath: imagePath, image: image) else {
            throw Err.invalid
        }
        self.imagePath = imagePath
        self.image = image
        self.placeholderImage = placeholderImage
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
