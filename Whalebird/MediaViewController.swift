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
    var animatedImageURL: NSURL?
    var blankView: UIView!
    var mediaImageView: MediaImageView?
    var animatedImageView: AnimatedImageView?
    var mediaScrollView: UIScrollView!
    var cWindowSize: CGRect!
    var fZoom: Bool = true
    
    //==============================================
    //  instance methods
    //==============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    convenience init(aMediaImage: UIImage!) {
        self.init()
        self.mediaImage = aMediaImage
    }
    
    convenience init(aGifImageURL: NSURL) {
        self.init()
        self.animatedImageURL = aGifImageURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wholeWindowSize = UIScreen.mainScreen().bounds
        self.cWindowSize = CGRectMake(
            wholeWindowSize.origin.x,
            wholeWindowSize.origin.y + UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height,
            wholeWindowSize.size.width,
            wholeWindowSize.size.height - (UIApplication.sharedApplication().statusBarFrame.size.height + self.navigationController!.navigationBar.frame.size.height)
        )
        
        self.mediaScrollView = UIScrollView(frame: self.view.bounds)
        self.mediaScrollView.backgroundColor = UIColor.blackColor()
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
        self.mediaScrollView.scrollEnabled = true
        self.mediaScrollView.showsHorizontalScrollIndicator = true
        self.mediaScrollView.showsVerticalScrollIndicator = true
        self.view.addSubview(self.mediaScrollView)
        
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MediaViewController.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.mediaScrollView.addGestureRecognizer(doubleTapGesture)

        let closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(MediaViewController.closeView))
        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.blankView
    }
    
    
    func doubleTap(gesture: UITapGestureRecognizer) {
        // ここ拡大縮小させたい
        if self.fZoom {
            let zoomRect = self.zoomRectToScale(2.0, center: gesture.locationInView(gesture.view))
            self.mediaScrollView.zoomToRect(zoomRect, animated: true)
            self.fZoom = false
        } else {
            self.mediaScrollView.setZoomScale(1.0, animated: true)
            self.fZoom = true
        }
    }
    
    func zoomRectToScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.mediaScrollView.frame.size.height / scale
        zoomRect.size.width = self.mediaScrollView.frame.size.width / scale
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        return zoomRect
    }
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
