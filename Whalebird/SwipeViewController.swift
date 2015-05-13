//
//  SwipeViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/12/05.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class SwipeViewController: UIViewController, SwipeViewDelegate, SwipeViewDataSource, UINavigationControllerDelegate, UITabBarControllerDelegate {

    //=============================================
    //  class variables
    //=============================================
    static let PageControlViewHeight = CGFloat(20)
    
    //=============================================
    //  instance variables
    //=============================================
    var swipeView: SwipeView!
    
    var pageControl: UIPageControl!
    var swipeItems: Array<ListTableViewController.Stream> = []
    var viewItems: Array<StreamTableViewController> = []
    var startIndex = Int(0)
    var currentScroll: Array<CGPoint> = []

    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(aStream: Array<ListTableViewController.Stream>, aStartIndex: Int?) {
        self.init()
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
        self.swipeView = SwipeView(frame: CGRectMake(
            0,
            self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.height,
            self.view.frame.width,
            self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - UIApplication.sharedApplication().statusBarFrame.height - SwipeViewController.PageControlViewHeight
            ))
        
        self.swipeView.delegate = self
        self.swipeView.dataSource = self
        
        self.swipeView.pagingEnabled = true
        self.swipeView.currentPage = self.startIndex
        self.navigationItem.title = self.swipeItems[self.startIndex].name
        self.view.addSubview(self.swipeView)
        
        var newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "tappedNewTweet")
        self.navigationItem.rightBarButtonItem = newTweetButton
        
        let cWindowSize = UIScreen.mainScreen().bounds
        self.pageControl = UIPageControl(frame: CGRectMake(
            0,
            cWindowSize.size.height - self.tabBarController!.tabBar.frame.height - SwipeViewController.PageControlViewHeight,
            cWindowSize.size.width,
            SwipeViewController.PageControlViewHeight))
        self.pageControl.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.pageControl.pageIndicatorTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
        self.pageControl.numberOfPages = self.swipeItems.count
        self.pageControl.currentPage = self.startIndex
        self.view.addSubview(self.pageControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.delegate = nil
        self.tabBarController?.delegate = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.delegate = self
        self.tabBarController?.delegate = self
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
        for (var i = 0; i < self.swipeItems.count; i++) {
            if (!self.viewItems[i].fCellSelect) {
                self.viewItems[i].setCurrentOffset(self.currentScroll[i])
            }
        }
    }

    // Cell選択周りではsetCurrentOffsetを実行したくないので，Navigationの戻るイベントを検出してフラグの書き換え
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if (viewController.dynamicType === SwipeViewController.self) {
            for (var i = 0; i < self.swipeItems.count; i++) {
                self.viewItems[i].fCellSelect = false
            }
        }
    }

    func tappedNewTweet() {
        for (var i = 0; i < self.swipeItems.count; i++) {
            self.currentScroll[i] = self.viewItems[i].getCurrentOffset()
        }
        var newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        for (var i = 0; i < self.swipeItems.count; i++) {
            self.currentScroll[i] = self.viewItems[i].getCurrentOffset()
        }
        return true
    }
}
