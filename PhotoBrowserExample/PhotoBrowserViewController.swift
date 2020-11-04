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

open class PhotoBrowserViewController: UIViewController {
    @IBOutlet weak public private(set) var headerView: UIView!
    @IBOutlet weak public private(set) var titleLabel: UILabel!
    @IBOutlet weak public private(set) var scrollView: UIScrollView!
    @IBOutlet weak public private(set) var bottomToolbar: UIToolbar!

    private let content: [PhotoPageContentRepresentable]
    private let photoViews: [AsyncImageView]
    private var mode: BrowserMode = .zoom
    /// To prevent overlapping tool bar fade animations
    private var isTransitioningBars: Bool = false
    public private(set) var currentPageIndex: Int {
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
    
    public init(content: [PhotoPageContentRepresentable], startIndex: Int = 0) {
        self.content = content
        self.photoViews = content.map { _ in AsyncImageView() }
        self.currentPageIndex = min(startIndex, content.count - 1)

        super.init(nibName: "PhotoBrowserViewController", bundle: nil)
    }

    required public init?(coder: NSCoder) {
        return nil
    }

    open override func viewDidLoad() {
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
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        update(mode: .paging)
    }
    
    // MARK: - Updating
    
    open func updateCurrentIndex(to index: Int) {
        guard index < content.count else {
            return
        }
        currentPageIndex = index
        configurePagingMode()
    }
    
    open func updateTitle() {
        titleLabel.text = "\(currentPageIndex + 1) of \(content.count)"
        updateToolBars(shouldShow: true, delay: 0.25)
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
    
    private func updateToolBars(shouldShow: Bool, delay: TimeInterval = 0) {
        guard !isTransitioningBars else {
            return
        }
        isTransitioningBars = true
        
        UIView.animate(withDuration: 0.25, delay: delay, animations: { [weak self] in
            let alpha: CGFloat = shouldShow ? 1 : 0
            self?.bottomToolbar.alpha = alpha
            self?.headerView.alpha = alpha
        }, completion: { [weak self]  _ in
            self?.isTransitioningBars = false
        })
    }
    
    // MARK: - Actions
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        let shouldShow = headerView.alpha == 1 ? false : true
        updateToolBars(shouldShow: shouldShow)
    }
    
    @IBAction open func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Configuration
    
    private func configureZoomMode() {
        let frame = scrollView.frame
        
        scrollView.contentSize = frame.size
        scrollView.isPagingEnabled = false
        scrollView.isDirectionalLockEnabled = false
        
        resetScrollViewContent()
        currentPhotoView?.frame = frame
        
        updateToolBars(shouldShow: false)
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
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let isPagingMode = scrollView.subviews.count > 1
        
        if isPagingMode {
            currentPageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        }
    }
    
    // MARK: - Zooming
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        update(mode: .zoom)
        return currentPhotoView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale <= 1.25 {
            scrollView.setZoomScale(1, animated: true)
            update(mode: .paging)
        }
    }
}
