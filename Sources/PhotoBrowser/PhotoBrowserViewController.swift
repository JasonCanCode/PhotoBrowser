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
    public private(set) lazy var headerView = createHeaderView()
    public private(set) var titleLabel = UILabel()
    public private(set) lazy var closeButton = createCloseButton()
    public private(set) lazy var scrollView = createScrollView()
    public private(set) lazy var bottomToolbar = UIToolbar()
    
    public private(set) var currentPageIndex: Int = 0 {
        willSet {
            if newValue < photoViews.count {
                currentPhotoView = photoViews[newValue]
            }
        }
        didSet {
            updateTitle()
            preloadImageViews()
        }
    }

    private var content: [PhotoPageContentRepresentable] = [] {
        didSet {
            photoViews = content.map { _ in AsyncImageView() }
        }
    }
    private var photoViews: [AsyncImageView] = []
    private var currentPhotoView: AsyncImageView?
    private var mode: BrowserMode = .zoom
    /// To prevent overlapping tool bar fade animations
    private var isTransitioningBars: Bool = false
    
    private var hasNav: Bool {
        return navigationController?.isNavigationBarHidden == false
    }
    
    // MARK: - Setup
    
    open func configure(content: [PhotoPageContentRepresentable], startIndex: Int = 0) {
        guard !content.isEmpty else {
            return
        }
        loadViewIfNeeded()
        let index = min(startIndex, content.count - 1)
        
        self.content = content
        self.currentPageIndex = index
        self.currentPhotoView = photoViews[index]
        
        configureZoomMode()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        arrangeViews()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        update(mode: .paging)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTitle()
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
        headerView.isHidden = hasNav
        
        let text = "\(currentPageIndex + 1) of \(content.count)"
        
        if hasNav {
            navigationItem.title = text
        } else {
            titleLabel.text = text
            updateToolBars(shouldShow: true, delay: 0.25)
        }
    }
    
    private func update(mode: BrowserMode) {
        guard self.mode != mode else {
            return
        }
        
        switch mode {
        case .paging:
            if !scrollView.isZooming, scrollView.zoomScale == 1 {
                configurePagingMode()
                self.mode = mode
            }
        case .zoom:
            configureZoomMode()
            self.mode = mode
        }
    }
    
    private func updateToolBars(shouldShow: Bool, delay: TimeInterval = 0) {
        guard !isTransitioningBars else {
            return
        }
        let shouldShowHeader = shouldShow && !hasNav
        let shouldShowFooter = shouldShow && bottomToolbar.items?.isEmpty == false
        
        isTransitioningBars = true
        
        UIView.animate(withDuration: 0.25, delay: delay, animations: { [weak self] in
            self?.headerView.alpha = shouldShowHeader ? 1 : 0
            self?.bottomToolbar.alpha = shouldShowFooter ? 1 : 0
        }, completion: { [weak self]  _ in
            self?.isTransitioningBars = false
        })
    }
    
    // MARK: - Actions
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        let shouldShow = headerView.alpha == 1 ? false : true
        updateToolBars(shouldShow: shouldShow)
    }
    
    @IBAction func viewDoubleTapped(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            update(mode: .zoom)
            scrollView.setZoomScale(2.5, animated: true)
        } else {
            resetZoom()
        }
    }
    
    @IBAction open func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Configuration
    
    private func configureZoomMode() {
        guard let currentPhotoView = currentPhotoView else {
            return
        }
        let frame = scrollView.frame
        
        scrollView.contentSize = frame.size
        scrollView.isPagingEnabled = false
        scrollView.isDirectionalLockEnabled = false
        
        resetScrollViewContent()
        currentPhotoView.frame = frame
        
        if !scrollView.subviews.contains(currentPhotoView) {
            scrollView.addSubview(currentPhotoView)
        }
        
        updateToolBars(shouldShow: false)
    }
    
    private func configurePagingMode() {
        guard !scrollView.isZooming, scrollView.zoomScale == 1 else {
            return
        }
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
        let isPaging = scrollView.subviews.count > 1 && mode == .paging
        var newIndex = currentPageIndex
        
        for (i, photoView) in photoViews.enumerated() {
            if scrollView.contentOffset == photoView.frame.origin {
                newIndex = i
                break
            }
        }
        
        if isPaging, newIndex == currentPageIndex - 1 || newIndex == currentPageIndex + 1 {
            currentPageIndex = newIndex
        }
    }
    
    // MARK: - Zooming
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentPhotoView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        guard view == currentPhotoView else {
            return
        }
        update(mode: .zoom)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale < 1 {
            resetZoom()
        }
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        update(mode: .paging)
    }
    
    private func resetZoom() {
        let viewFrame = self.view.frame
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.25, delay: 0) { [weak self] in
            self?.currentPhotoView?.bounds = viewFrame
            self?.scrollView.setZoomScale(1, animated: false)
        } completion: { [weak self] _ in
            self?.view.isUserInteractionEnabled = true
            self?.update(mode: .paging)
        }
    }
}
