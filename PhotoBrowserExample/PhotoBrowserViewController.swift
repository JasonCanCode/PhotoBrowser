//
//  PhotoBrowserViewController.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

class PhotoBrowserViewController: UIViewController {
    @IBOutlet weak private var navBar: UINavigationBar!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var bottomToolbar: UIToolbar!

    private let content: [PhotoPageContentRepresentable]
    private let pagingViewController: PhotoPagingViewController

    init(content: [PhotoPageContentRepresentable]) {
        self.content = content
        self.pagingViewController = PhotoPagingViewController()
        self.pagingViewController.content = content

        super.init(nibName: "PhotoBrowserViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let childVC = pagingViewController
        addChild(childVC)
        //Or, you could add auto layout constraint instead of relying on AutoResizing contraints
        childVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        childVC.view.frame = containerView.bounds

        containerView.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }


    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }

}
