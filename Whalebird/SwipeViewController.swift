//
//  SwipeViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/12/05.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class SwipeViewController: UIViewController, SwipeViewDelegate, SwipeViewDataSource {
    let PageControlViewHeight = CGFloat(20)
    var swipeView: SwipeView!
    
    var pageControl: UIPageControl!
    var swipeItems: Array<ListTableViewController.Stream> = []
    var viewItems: Array<StreamTableViewController> = []
    var startIndex = Int(0)
    var currentScroll: Array<CGPoint> = []

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init() {
        super.init()
    }
    
    init(aStream: Array<ListTableViewController.Stream>, aStartIndex: Int?) {
        super.init()
        self.swipeItems = aStream
        if (aStartIndex != nil) {
            self.startIndex = aStartIndex!
        }
        for view in self.swipeItems {
            self.currentScroll.append(CGPoint(x: 0, y: 0))
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for item in self.swipeItems {
            viewItems.append(StreamTableViewController(aStreamElement: item, aParentNavigation: self.navigationController!))
        }
        self.swipeView = SwipeView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.height, self.view.frame.width, self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - UIApplication.sharedApplication().statusBarFrame.height))
        
        self.swipeView.delegate = self
        self.swipeView.dataSource = self
        
        self.swipeView.pagingEnabled = true
        self.swipeView.currentPage = self.startIndex
        self.view.addSubview(self.swipeView)
        
        var newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "tappedNewTweet")
        self.navigationItem.rightBarButtonItem = newTweetButton
        
        let cWindowSize = UIScreen.mainScreen().bounds
        self.pageControl = UIPageControl(frame: CGRectMake(
            0,
            cWindowSize.size.height - self.tabBarController!.tabBar.frame.height - self.PageControlViewHeight,
            cWindowSize.size.width,
            self.PageControlViewHeight))
        self.pageControl.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        self.pageControl.pageIndicatorTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
        self.pageControl.numberOfPages = self.swipeItems.count
        self.pageControl.currentPage = self.startIndex
        self.view.addSubview(self.pageControl)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return swipeItems.count
    }

    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        return self.viewItems[index].tableView
    }
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return self.swipeView.bounds.size
    }
    
    func swipeViewCurrentItemIndexDidChange(swipeView: SwipeView!) {
        self.navigationItem.title = self.swipeItems[swipeView.currentItemIndex].name
        if (self.pageControl != nil) {
            self.pageControl.currentPage = swipeView.currentItemIndex
        }
    }
    
    func swipeViewWillBeginDragging(swipeView: SwipeView!) {
        //self.currentScroll = self.viewItems[self.swipeView.currentItemIndex].tableView.contentOffset
        for (var i = 0; i < self.swipeItems.count; i++) {
            self.currentScroll[i] = self.viewItems[i].getCurrentOffset()
        }
        //self.viewItems[self.swipeView.currentItemIndex].tableView.scrollEnabled = false
    }
    
    func swipeViewDidScroll(swipeView: SwipeView!) {
        // ここが正解 TODO: itemIndexごとに作ろう
        for (var i = 0; i < self.swipeItems.count; i++) {
            self.viewItems[i].setCurrentOffset(self.currentScroll[i])
        }
    }
    
    func tappedNewTweet() {
        var newTweetView = NewTweetViewController()
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
}
