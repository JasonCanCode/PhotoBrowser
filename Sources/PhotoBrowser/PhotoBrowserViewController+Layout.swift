//
//  PhotoBrowserViewController+Layout.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/5/20.
//

import UIKit

internal extension PhotoBrowserViewController {
    
    func arrangeViews() {
        guard view.subviews.contains(scrollView) == false else {
            return
        }
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(viewDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.centerInSuperView(beSafe: false)
        scrollView.constrainSizetoSuperView(beSafe: false)
        
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.alignToSuperView(edges: [.left, .right, .top], beSafe: false)
        headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        
        headerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        closeButton.alignToSuperView(edges: [.bottom])
        
        
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: closeButton.trailingAnchor, constant: 8).isActive = true
        titleLabel.alignToSuperView(edges: [.bottom])
        
        let dividerView = UIView(frame: .zero)
        dividerView.backgroundColor = .lightGray
        headerView.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        dividerView.alignToSuperView(edges: [.left, .right, .bottom], beSafe: false)
        
        view.addSubview(bottomToolbar)
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        bottomToolbar.alignToSuperView(edges: [.left, .right, .bottom])
        
        view.sendSubviewToBack(scrollView)
        
        view.setNeedsUpdateConstraints()
        view.setNeedsLayout()
    }
    
    func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.frame = UIScreen.main.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        scrollView.bouncesZoom = false
        return scrollView
    }
    
    func createHeaderView() -> UIView {
        let header = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        if #available(iOS 13.0, *) {
            header.backgroundColor = .systemBackground
        } else {
            header.backgroundColor = UIColor.lightGray
        }
        
        return header
    }
    
    func createCloseButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        return button
    }
}

private extension UIView {
    
    func alignToSuperView(edges: UIRectEdge, beSafe: Bool = true) {
        guard let container = self.superview else {
            return
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let anchor = beSafe ? container.safeAreaLayoutGuide.topAnchor : container.topAnchor
            self.topAnchor.constraint(equalTo: anchor).isActive = true
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let anchor = beSafe ? container.safeAreaLayoutGuide.bottomAnchor : container.bottomAnchor
            self.bottomAnchor.constraint(equalTo: anchor).isActive = true
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let anchor = beSafe ? container.safeAreaLayoutGuide.leadingAnchor : container.leadingAnchor
            self.leadingAnchor.constraint(equalTo: anchor).isActive = true
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let anchor = beSafe ? container.safeAreaLayoutGuide.trailingAnchor : container.trailingAnchor
            self.trailingAnchor.constraint(equalTo: anchor).isActive = true
        }
    }
    
    func centerInSuperView(shouldUseVertical: Bool = true, shouldUseHorizontal: Bool = true, beSafe: Bool = true) {
        guard let container = self.superview else {
            return
        }
        
        if shouldUseVertical {
            let anchor = beSafe ? container.safeAreaLayoutGuide.centerYAnchor : container.centerYAnchor
            self.centerYAnchor.constraint(equalTo: anchor).isActive = true
        }
        
        if shouldUseHorizontal {
            let anchor = beSafe ? container.safeAreaLayoutGuide.centerXAnchor : container.centerXAnchor
            self.centerXAnchor.constraint(equalTo: anchor).isActive = true
        }
    }
    
    func constrainSizetoSuperView(shouldUseWidth: Bool = true, shouldUseHeight: Bool = true, beSafe: Bool = true) {
        guard let container = self.superview else {
            return
        }
        
        if shouldUseWidth {
            let anchor = beSafe ? container.safeAreaLayoutGuide.widthAnchor : container.widthAnchor
            self.widthAnchor.constraint(equalTo: anchor).isActive = true
        }
        
        if shouldUseHeight {
            let anchor = beSafe ? container.safeAreaLayoutGuide.heightAnchor : container.heightAnchor
            self.heightAnchor.constraint(equalTo: anchor).isActive = true
        }
    }
}
