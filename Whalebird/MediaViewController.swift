//
//  MediaViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/12.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit
import SDWebImage

class MediaViewController: UIViewController, UIScrollViewDelegate {
    
    //=============================================
    //  instance variables
    //=============================================
    var mediaImage: UIImage?
    var animatedImageURL: URL?
    var blankView: UIView!
    var mediaImageView: MediaImageView?
    var animatedImageView: AnimatedImageView?
    var mediaScrollView: UIScrollView!
    var cWindowSize: CGRect!
    var fZoom: Bool = true
    
    //==============================================
    //  instance methods
    //==============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    convenience init(aMediaImage: UIImage!) {
        self.init()
        self.mediaImage = aMediaImage
    }
    
    convenience init(aGifImageURL: URL) {
        self.init()
        self.animatedImageURL = aGifImageURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wholeWindowSize = UIScreen.main.bounds
        self.cWindowSize = CGRect(
            x: wholeWindowSize.origin.x,
            y: wholeWindowSize.origin.y + UIApplication.shared.statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height,
            width: wholeWindowSize.size.width,
            height: wholeWindowSize.size.height - (UIApplication.shared.statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height)
        )
        
        self.mediaScrollView = UIScrollView(frame: self.view.bounds)
        self.mediaScrollView.backgroundColor = UIColor.black
        // ピンチインで拡大縮小する対象としてblankViewを用意しておく
        self.blankView = UIView(frame: self.view.bounds)
        
        if self.mediaImage != nil {
            self.mediaImageView = MediaImageView(image: self.mediaImage!, windowSize: self.cWindowSize)
            self.blankView.addSubview(self.mediaImageView!)
        } else if self.animatedImageURL != nil {
            self.animatedImageView = AnimatedImageView(animatedImageURL: self.animatedImageURL!, windowSize: self.cWindowSize)
            self.blankView.addSubview(self.animatedImageView!)
        }
        
        self.mediaScrollView.addSubview(self.blankView)
        
        self.mediaScrollView.delegate = self
        self.mediaScrollView.minimumZoomScale = 1
        self.mediaScrollView.maximumZoomScale = 8
        self.mediaScrollView.isScrollEnabled = true
        self.mediaScrollView.showsHorizontalScrollIndicator = true
        self.mediaScrollView.showsVerticalScrollIndicator = true
        self.view.addSubview(self.mediaScrollView)
        
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MediaViewController.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.mediaScrollView.addGestureRecognizer(doubleTapGesture)

        let closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(MediaViewController.closeView))
        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.barTintColor = UIColor.black

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.blankView
    }
    
    
    func doubleTap(_ gesture: UITapGestureRecognizer) {
        // ここ拡大縮小させたい
        if self.fZoom {
            let zoomRect = self.zoomRectToScale(2.0, center: gesture.location(in: gesture.view))
            self.mediaScrollView.zoom(to: zoomRect, animated: true)
            self.fZoom = false
        } else {
            self.mediaScrollView.setZoomScale(1.0, animated: true)
            self.fZoom = true
        }
    }
    
    func zoomRectToScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.mediaScrollView.frame.size.height / scale
        zoomRect.size.width = self.mediaScrollView.frame.size.width / scale
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        return zoomRect
    }
    
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }

}
