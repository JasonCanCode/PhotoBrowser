//
//  ViewController.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

class ViewController: UIViewController {

    @IBAction private func showBrowserTapped(sender: UIButton) {
        let imagePaths = [
            "https://www.thelabradorsite.com/wp-content/uploads/2019/03/Cute-puppy-Names-Over-200-Adorable-Ideas-LS-long.jpg",
            "https://i.redd.it/bkwgp8qpegjy.jpg",
            "https://en.bcdn.biz/Images/2016/11/15/776342f0-86f5-4522-84c9-a02d6b11c766.jpg",
            "https://swall.teahub.io/photos/small/228-2288856_puppy-wallpapers-for-iphone.jpg",
            "https://cdn.shortpixel.ai/client/q_glossy,ret_img,w_520/https://coolbrnd.com/wp-content/uploads/2019/12/1-w1Dpk9Ufui0-520x926.jpg"
        ]
        let content: [PhotoPageContentRepresentable] = imagePaths.map { PhotoPageContent(imagePath: $0) }
        let vc = PhotoBrowserViewController(content: content, startIndex: 3)
        present(vc, animated: true, completion: nil)
    }
}
