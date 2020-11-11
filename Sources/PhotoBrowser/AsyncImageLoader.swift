//
//  AsyncImageLoader.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

// MARK: - ImageLoader Protocol

public typealias ImageLoaderHandler = (UIImage?, Error?) -> Void

public protocol ImageLoader {
    func updateImage(fromURLString urlString: String?, placeholderImage: UIImage?, completionHandler: @escaping ImageLoaderHandler)
    func imageFromCache(_ urlString: String?) -> UIImage?
}

extension ImageLoader {
    func updateImage(fromURL url: URL?, placeholderImage: UIImage? = nil, completionHandler: @escaping ImageLoaderHandler) {
        updateImage(fromURLString: url?.absoluteString, placeholderImage: placeholderImage, completionHandler: completionHandler)
    }
    
    func imageFromCache(_ url: URL?) -> UIImage? {
        imageFromCache(url?.absoluteString)
    }
}

// MARK: - AsyncImageLoader class

public class AsyncImageLoader: ImageLoader {
    private var task: URLSessionDownloadTask?
    private var session: URLSession
    private var imageCache: NSCache<AnyObject, UIImage>
    
    private(set) static var shared = AsyncImageLoader(session: URLSession.shared, imageCache: NSCache<AnyObject, UIImage>())
    
    init(session: URLSession, imageCache: NSCache<AnyObject, UIImage>) {
        self.task = nil
        self.session = session
        self.imageCache = imageCache
    }

    /**
     Load an image on a separate thread and use the result in a provided completion block.

     - parameter urlString:         Converted into an `NSURL` for requesting an image.
     - parameter placeholderImage:  Optional image to apply using the provided completion handler while the desired image is loaded.
     - parameter completionHandler: A block that receives both a `UIImage` (on succuess) and an `AsyncImageError` (on failure).
     */
    public func updateImage(fromURLString urlString: String?, placeholderImage: UIImage? = nil, completionHandler: @escaping ImageLoaderHandler) {

        // Threading for handlers
        let completeWithError: (Err) -> Void = { customError in
            DispatchQueue.main.async {
                completionHandler(nil, customError)
            }
        }
        let completeWithImage: (UIImage) -> Void = { image in
            DispatchQueue.main.async {
                completionHandler(image, nil)
            }
        }

        if let img = imageFromCache(urlString) {
            // The image has already been loaded from the provided URL. We pull it from our cached images and forego the request.
            completeWithImage(img)
            return
        } else if let placeholder = placeholderImage {
            // Use completion block to insert the placeholder image while we are loading the actual image.
            completeWithImage(placeholder)
        }

        guard let urlString = urlString, let url = URL(string: urlString) else {
            completeWithError(.invalidURL)
            return
        }

        task = session.downloadTask(with: url, completionHandler: { _, _, error in
            // Attempt to load the image on a backgroung thread
            if let error = error {
                completeWithError(.downloadError(error: error))
                return

            } else if let data = try? Data(contentsOf: url) {

                if let img = UIImage(data: data) {
                    self.imageCache.setObject(img, forKey: urlString as AnyObject)
                    completeWithImage(img)
                } else {
                    completeWithError(.faultyImageFromData)
                }
                return
            } else {
                completeWithError(.faultyDataFromURL)
                return
            }
        })
        task?.resume()
    }

    /**
     Retrieve an image that has already been loaded using AsyncImageLoader

     - parameter urlString: The url previously used to load the image.

     - returns: The matching image if it was successfully loaded
     */
    public func imageFromCache(_ urlString: String?) -> UIImage? {
        guard let urlString = urlString else {
            return nil
        }

        return imageCache.object(forKey: urlString as AnyObject)
    }
    
    public enum Err: Error {
        case invalidURL
        case downloadError(error: Error)
        case faultyDataFromURL
        case faultyImageFromData
    }
}

