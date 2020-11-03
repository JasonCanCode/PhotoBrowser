//
//  PhotoViewController.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak private(set) var photoImageView: AsyncImageView!

    init(imagePath: String, placeholderImage: UIImage? = nil) {
        super.init(nibName: "PhotoViewController", bundle: nil)

        loadViewIfNeeded()
        photoImageView.updateImage(fromURLString: imagePath, placeholderImage: placeholderImage)
    }

    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: - Zooming

extension PhotoViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
}
