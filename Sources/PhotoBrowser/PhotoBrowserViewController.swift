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

    private var content: [PhotoBrowserContentRepresentable] = [] {
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
    
    open func configure(content: [PhotoBrowserContentRepresentable], startIndex: Int = 0) {
        guard !content.isEmpty else {
            return
        }
        
        // Make sure all content objects are valid
        if content.lazy.first(where: { !$0.isValid }) != nil {
            assertionFailure("All content objects must have either a image path or image")
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
        
        let needsCloseButton: Bool = navigationController != nil
            && navigationItem.backBarButtonItem == nil
            && navigationItem.leftBarButtonItem == nil

        if needsCloseButton {
            navigationItem.leftBarButtonItem = createCloseNavButton()
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let index = currentPageIndex
        coordinator.animate { [weak self] _ in
            self?.updateCurrentIndex(to: index)
        }
    }
    
    // MARK: - Updating
    
    /// External access to updating the `currentPageIndex`
    /// - Parameter index: New content page index
    open func updateCurrentIndex(to index: Int) {
        guard index < content.count else {
            return
        }
        currentPageIndex = index
        configurePagingMode()
    }
    
    /// Update the header/nav bar title to show which image within the collection the user is viewing (ex.  "5 of 32")
    open func updateTitle() {
        headerView.isHidden = hasNav
        
        let text = "\(currentPageIndex + 1) of \(content.count)"
        
        if hasNav {
            navigationItem.title = text
        } else {
            titleLabel.text = text
            updateToolBars(shouldShow: true)
        }
    }
    
    /// Add items to a footer toolbar, such as a like button. These buttons will be right aligned.
    /// - Parameter item: Button to be added to the far right of the footer tool bar.
    open func addToFooter(item: UIBarButtonItem) {
        let hasButtons = bottomToolbar.items?.isEmpty == false
        
        if !hasButtons {
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            bottomToolbar.items = [spacer]
        }
        bottomToolbar.items?.append(item)
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
    
    private func updateToolBars(shouldShow: Bool) {
        guard !isTransitioningBars else {
            return
        }
        let shouldShowHeader = shouldShow && !hasNav
        let shouldShowFooter = shouldShow && bottomToolbar.items?.isEmpty == false
        
        isTransitioningBars = true
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.headerView.alpha = shouldShowHeader ? 1 : 0
            self?.bottomToolbar.alpha = shouldShowFooter ? 1 : 0
        }, completion: { [weak self]  _ in
            self?.isTransitioningBars = false
        })
    }
    
    // MARK: - Actions
    
    /// Show/hide header and/or footer when screen is tapped.
    @IBAction open func viewTapped(_ sender: UITapGestureRecognizer) {
        let shouldShow = headerView.alpha == 1 ? false : true
        updateToolBars(shouldShow: shouldShow)
    }
    
    /// Zoom in/out with screen is double tapped.
    @IBAction open func viewDoubleTapped(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            update(mode: .zoom)
            scrollView.setZoomScale(2.5, animated: true)
        } else {
            resetZoom()
        }
    }
    
    /// Dismiss this PhotoBrowserViewController
    @IBAction open func close() {
        if let nav = navigationController, nav.viewControllers.count > 1, nav.viewControllers.last == self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
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
            let photoView = photoViews[i]
            
            if let image = contentItem.image {
                photoView.image = image
            } else if let path = contentItem.imagePath, photoViews[i].urlString != path {
                photoViews[i].contentMode = .scaleAspectFit
                photoViews[i].updateImage(fromURLString: path)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoBrowserViewController: UIScrollViewDelegate {
    
    // MARK: - Paging
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePageIndexIfNecessary()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageIndexIfNecessary()
    }
    
    private func updatePageIndexIfNecessary() {
        let newIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        
        if mode == .paging,
           scrollView.subviews.count > 1,
           0 ..< content.count ~= newIndex,
           newIndex == currentPageIndex - 1 || newIndex == currentPageIndex + 1,
           !scrollView.isZooming,
           !isTransitioningBars {

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
