//
//  PhotoBrowserViewController.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

class PhotoBrowserViewController: UIViewController {
    @IBOutlet weak private var photoImageView: AsyncImageView!

    init(imagePath: String) {
        super.init(nibName: "PhotoBrowserViewController", bundle: nil)

        loadViewIfNeeded()
        photoImageView.updateImage(fromURLString: imagePath)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - Zooming

extension PhotoBrowserViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
}
