//
//  ViewController.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction private func showBrowserTapped(sender: UIButton) {
        let vc = PhotoBrowserViewController(imagePath: "https://en.bcdn.biz/Images/2016/11/15/776342f0-86f5-4522-84c9-a02d6b11c766.jpg")
        present(vc, animated: true, completion: nil)
    }
}
