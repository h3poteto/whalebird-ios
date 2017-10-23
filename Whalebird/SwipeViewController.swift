//
//  SwipeViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/12/05.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SwipeView
import ODRefreshControl
import SVProgressHUD

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
    var streamList: StreamList!
    var viewItems: Array<StreamTableViewController> = []
    var startIndex = Int(0)
    var currentScroll: Array<CGPoint> = []

    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(aStreamList: StreamList, aStartIndex: Int?) {
        self.init()
        self.streamList = aStreamList
        if (aStartIndex != nil) {
            self.startIndex = aStartIndex!
        }
        for _ in 0 ..< self.streamList.count() {
            self.currentScroll.append(CGPoint(x: 0, y: 0))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for item in self.streamList.lists {
            viewItems.append(StreamTableViewController(aStreamElement: item, aParentNavigation: self.navigationController!))
        }
        self.swipeView = SwipeView(frame: CGRect(
            x: 0,
            y: self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.height,
            width: self.view.frame.width,
            height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - UIApplication.shared.statusBarFrame.height - SwipeViewController.PageControlViewHeight
            ))
        
        self.swipeView.delegate = self
        self.swipeView.dataSource = self
        
        self.swipeView.isPagingEnabled = true
        self.swipeView.currentPage = self.startIndex
        self.navigationItem.title = self.streamList.getStreamAtIndex(self.startIndex).name
        self.view.addSubview(self.swipeView)
        
        let newTweetButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(SwipeViewController.tappedNewTweet))
        self.navigationItem.rightBarButtonItem = newTweetButton
        
        let cWindowSize = UIScreen.main.bounds
        self.pageControl = UIPageControl(frame: CGRect(
            x: 0,
            y: cWindowSize.size.height - self.tabBarController!.tabBar.frame.height - SwipeViewController.PageControlViewHeight,
            width: cWindowSize.size.width,
            height: SwipeViewController.PageControlViewHeight))
        self.pageControl.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.pageControl.pageIndicatorTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
        self.pageControl.numberOfPages = self.streamList.count()
        self.pageControl.currentPage = self.startIndex
        self.view.addSubview(self.pageControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.delegate = nil
        self.tabBarController?.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.delegate = self
        self.tabBarController?.delegate = self
    }

    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return self.streamList.count()
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        return self.viewItems[index].tableView
    }
    
    func swipeViewItemSize(_ swipeView: SwipeView!) -> CGSize {
        return self.swipeView.bounds.size
    }
    
    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        self.navigationItem.title = self.streamList.getStreamAtIndex(swipeView.currentItemIndex).name
        if (self.pageControl != nil) {
            self.pageControl.currentPage = swipeView.currentItemIndex
        }
    }

    func swipeViewWillBeginDragging(_ swipeView: SwipeView!) {
        //self.currentScroll = self.viewItems[self.swipeView.currentItemIndex].tableView.contentOffset
        for i in 0 ..< self.streamList.count() {
            self.currentScroll[i] = self.viewItems[i].getCurrentOffset()
        }
        //self.viewItems[self.swipeView.currentItemIndex].tableView.scrollEnabled = false
    }
    
    func swipeViewDidScroll(_ swipeView: SwipeView!) {
        for i in 0 ..< self.streamList.count() {
            if (!self.viewItems[i].fCellSelect) {
                self.viewItems[i].setCurrentOffset(self.currentScroll[i])
            }
        }
    }

    // Cell選択周りではsetCurrentOffsetを実行したくないので，Navigationの戻るイベントを検出してフラグの書き換え
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if (type(of: viewController) === SwipeViewController.self) {
            for i in 0 ..< self.streamList.count() {
                self.viewItems[i].fCellSelect = false
            }
        }
    }

    @objc func tappedNewTweet() {
        for i in 0 ..< self.streamList.count() {
            self.currentScroll[i] = self.viewItems[i].getCurrentOffset()
        }
        let newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        for i in 0 ..< self.streamList.count() {
            self.currentScroll[i] = self.viewItems[i].getCurrentOffset()
        }
        return true
    }
}
