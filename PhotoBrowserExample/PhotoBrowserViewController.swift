//
//  PhotoBrowserViewController.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

private enum BrowserMode {
    case paging
    case zoom
}

class PhotoBrowserViewController: UIViewController {
    @IBOutlet weak private var navBar: UINavigationItem!
    @IBOutlet weak private(set) var scrollView: UIScrollView!
    @IBOutlet weak private var bottomToolbar: UIToolbar!

    private let content: [PhotoPageContentRepresentable]
    private let pagingViewController: PhotoPagingViewController
    private var currentPageIndex = 0 {
        didSet {
            updateTitle()
        }
    }
    private var mode: BrowserMode = .zoom
    
    private let photoViews: [AsyncImageView]
    private var currentPhotoView: AsyncImageView? {
        guard currentPageIndex < photoViews.count else {
            return nil
        }
        return photoViews[currentPageIndex]
    }

    init(content: [PhotoPageContentRepresentable]) {
        self.content = content
        self.pagingViewController = PhotoPagingViewController()
        self.pagingViewController.content = content
        
        self.photoViews = content.map {
            let view = AsyncImageView()
            view.updateImage(fromURLString: $0.imagePath, placeholderImage: $0.placeholderImage)
            view.contentMode = .scaleAspectFit
            return view
        }

        super.init(nibName: "PhotoBrowserViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 1
        updateTitle()
        configureZoomMode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        update(mode: .paging)
    }
    
    private func updateTitle() {
        navBar.title = "\(currentPageIndex + 1) of \(content.count)"
    }
    
    private func update(mode: BrowserMode) {
        if self.mode != mode {
            self.mode = mode
            
            switch mode {
            case .paging:
                configurePagingMode()
            case .zoom:
                configureZoomMode()
            }
        }
    }
    
    private func configureZoomMode() {
        let width = UIScreen.main.bounds.size.width
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: width, height: scrollView.frame.height)
        scrollView.isPagingEnabled = false
        scrollView.isDirectionalLockEnabled = false
        
        scrollView.subviews.forEach {
            if $0 != currentPhotoView {
                $0.removeFromSuperview()
            }
        }
        currentPhotoView?.frame = CGRect(x: 0, y: 0, width: width, height: scrollView.frame.height)
    }
    
    private func configurePagingMode() {
        let width = UIScreen.main.bounds.size.width
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: width * CGFloat(photoViews.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = true
        
        for (i, imageView) in photoViews.enumerated() {
            imageView.frame = CGRect(x: width * CGFloat(i), y: 0, width: width, height: scrollView.frame.height)
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentOffset = CGPoint(x: width * CGFloat(currentPageIndex), y: 0)
    }

    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - Zooming

extension PhotoBrowserViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let isPagingMode = scrollView.subviews.count > 1
        
        if isPagingMode {
            currentPageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        }
    }
    
    // MARK: - Zoom
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        update(mode: .zoom)
        return currentPhotoView
    }
    
//    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//        update(mode: .zoom)
//    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale <= 1.25 {
            scrollView.setZoomScale(1, animated: true)
            update(mode: .paging)
        }
    }
}
