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
    @IBOutlet weak var bottomToolbar: UIToolbar!

    private let content: [PhotoPageContentRepresentable]
    private let photoViews: [AsyncImageView]
    private var mode: BrowserMode = .zoom
    private(set) var currentPageIndex: Int {
        didSet {
            updateTitle()
            preloadImageViews()
        }
    }
    
    private var currentPhotoView: AsyncImageView? {
        guard currentPageIndex < photoViews.count else {
            return nil
        }
        return photoViews[currentPageIndex]
    }
    
    // MARK: - Setup
    
    init(content: [PhotoPageContentRepresentable], startIndex: Int = 0) {
        self.content = content
        self.photoViews = content.map { _ in AsyncImageView() }
        self.currentPageIndex = min(startIndex, content.count - 1)

        super.init(nibName: "PhotoBrowserViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 1
        scrollView.frame = UIScreen.main.bounds
        updateTitle()
        
        if let view = currentPhotoView {
            scrollView.addSubview(view)
            configureZoomMode()
            preloadImageViews()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        update(mode: .paging)
    }
    
    // MARK: - Actions
    
    func updateCurrentIndex(to index: Int) {
        guard index < content.count else {
            return
        }
        currentPageIndex = index
        configurePagingMode()
    }
    
    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Configuration
    
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
        let frame = scrollView.frame
        
        scrollView.contentSize = frame.size
        scrollView.isPagingEnabled = false
        scrollView.isDirectionalLockEnabled = false
        
        resetScrollViewContent()
        currentPhotoView?.frame = frame
    }
    
    private func configurePagingMode() {
        let width = scrollView.frame.size.width
        let height = scrollView.frame.size.height
        
        scrollView.contentSize = CGSize(width: width * CGFloat(photoViews.count), height: height)
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = true
        
        resetScrollViewContent()
        
        for (i, imageView) in photoViews.enumerated() {
            imageView.frame = CGRect(x: width * CGFloat(i), y: 0, width: width, height: height)
            
            if !scrollView.subviews.contains(imageView) {
                scrollView.addSubview(imageView)
            }
        }

        scrollView.contentOffset = CGPoint(x: width * CGFloat(currentPageIndex), y: 0)
    }
    
    private func resetScrollViewContent() {
        scrollView.subviews.forEach {
            if $0 != currentPhotoView {
                $0.removeFromSuperview()
            }
        }
    }
    
    /// Load images of the visable image view and up to 2 in either direction
    private func preloadImageViews() {
        let firstPreloadIndex = max(0, currentPageIndex - 2)
        let lastPreloadIndex = min(photoViews.count - 1, currentPageIndex + 2)
        
        for i in firstPreloadIndex...lastPreloadIndex {
            let contentItem = content[i]
            
            if photoViews[i].urlString != contentItem.imagePath {
                photoViews[i].contentMode = .scaleAspectFit
                photoViews[i].updateImage(fromURLString: contentItem.imagePath)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoBrowserViewController: UIScrollViewDelegate {
    
    // MARK: - Paging
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let isPagingMode = scrollView.subviews.count > 1
        
        if isPagingMode {
            currentPageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        }
    }
    
    // MARK: - Zooming
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        update(mode: .zoom)
        return currentPhotoView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale <= 1.25 {
            scrollView.setZoomScale(1, animated: true)
            update(mode: .paging)
        }
    }
}
