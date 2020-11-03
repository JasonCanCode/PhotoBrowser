//
//  PhotoPagingViewController.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

protocol PhotoPageContentRepresentable {
    var imagePath: String { get }
    var placeholderImage: UIImage? { get }
}

extension PhotoPageContentRepresentable {
    var placeholderImage: UIImage? {
        return nil
    }
}

struct PhotoPageContent: PhotoPageContentRepresentable {
    let imagePath: String
    let placeholderImage: UIImage?

    init(imagePath: String, placeholderImage: UIImage? = nil) {
        self.imagePath = imagePath
        self.placeholderImage = placeholderImage
    }
}

class PhotoPagingViewController: PagedContentViewController {
    var content: [PhotoPageContentRepresentable] = [] {
        didSet {
            orderedViewControllers = content.map {
                PhotoViewController(imagePath: $0.imagePath, placeholderImage: $0.placeholderImage)
            }
        }
    }

    var photoViewControllers: [PhotoViewController] {
        orderedViewControllers.compactMap {
            $0 as? PhotoViewController
        }
    }
}
