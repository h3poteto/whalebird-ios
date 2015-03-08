//
//  MediaViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/12.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController, UIScrollViewDelegate {
    
    var mediaImage: UIImage!
    var blankView: UIView!
    var mediaImageView: UIImageView!
    var mediaScrollView: UIScrollView!
    var cWindowSize: CGRect!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    init(aMediaImage: UIImage!) {
        super.init()
        self.mediaImage = aMediaImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cWindowSize = UIScreen.mainScreen().bounds
        
        self.mediaScrollView = UIScrollView(frame: self.view.bounds)
        self.mediaScrollView.backgroundColor = UIColor.blackColor()
        self.mediaImageView = UIImageView(frame: self.view.bounds)
        self.mediaImageView.image = self.mediaImage
        self.mediaImageView.sizeToFit()
        // 初期状態では画面に収まるようにリサイズしておく
        if (self.mediaImageView.frame.size.width > self.cWindowSize.size.width) {
            var scale = self.cWindowSize.size.width / self.mediaImageView.frame.size.width
            self.mediaImageView.frame.size = CGSizeMake(self.cWindowSize.size.width, self.mediaImageView.frame.size.height * scale)
        }
        if (self.mediaImageView.frame.size.height > self.cWindowSize.size.height) {
            var scale = self.cWindowSize.size.height / self.cWindowSize.size.height
            self.mediaImageView.frame.size = CGSizeMake(self.mediaImageView.frame.size.width * scale, self.cWindowSize.size.height)
        }
        self.mediaImageView.center = CGPointMake(self.cWindowSize.size.width / 2.0, self.cWindowSize.size.height / 2.0)
        
        let closeImage = UIImage(named: "Close-Filled.png")
        var closeImagePosY: CGFloat = self.mediaImageView.frame.origin.y - closeImage!.size.height * 2.0
        if (closeImagePosY < 20.0) {
            closeImagePosY = 20.0
        }
        var closeButton = UIButton(frame: CGRectMake(closeImage!.size.width * 0.5, closeImagePosY, closeImage!.size.width * 1.5, closeImage!.size.height * 1.5))
        closeButton.setBackgroundImage(closeImage, forState: .Normal)
        closeButton.addTarget(self, action: "mediaClose", forControlEvents: UIControlEvents.TouchDown)
        
        // ピンチインで拡大縮小する対象としてblankViewを用意しておく
        self.blankView = UIView(frame: self.view.bounds)
        self.blankView.addSubview(self.mediaImageView)
        self.blankView.addSubview(closeButton)
        self.mediaScrollView.addSubview(self.blankView)
        
        self.mediaScrollView.delegate = self
        self.mediaScrollView.minimumZoomScale = 1
        self.mediaScrollView.maximumZoomScale = 8
        self.mediaScrollView.scrollEnabled = true
        self.mediaScrollView.showsHorizontalScrollIndicator = true
        self.mediaScrollView.showsVerticalScrollIndicator = true
        self.view.addSubview(self.mediaScrollView)
        
        var doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        self.mediaImageView.userInteractionEnabled = true
        self.mediaScrollView.addGestureRecognizer(doubleTapGesture)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.blankView
    }
    
    func doubleTap(sender: AnyObject) {
        self.mediaClose()
    }
    
    func mediaClose() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
