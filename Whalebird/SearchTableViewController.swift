//
//  SearchTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/12/10.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    //=============================================
    //  instance variables
    //=============================================
    var tweetCount = Int(50)
    var tweetSearchBar: UISearchBar!
    var currentResult: Array<AnyObject> = []
    var newResult: Array<AnyObject> = []
    var resultCell: Array<AnyObject> = []
    var saveButton: UIBarButtonItem!

    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let window = UIScreen.mainScreen().bounds
        self.tweetSearchBar = UISearchBar()
        self.tweetSearchBar.placeholder = "検索"
        self.tweetSearchBar.keyboardType = UIKeyboardType.Default
        self.tweetSearchBar.delegate = self
        
        self.navigationItem.titleView = self.tweetSearchBar
        self.tweetSearchBar.becomeFirstResponder()
        
        self.saveButton = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: "saveResult")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.currentResult.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
        }
        
        self.resultCell.insert(cell!, atIndex: indexPath.row)

        cell!.cleanCell()
        cell!.configureCell(self.currentResult[indexPath.row] as! NSDictionary)
        // Configure the cell...

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.resultCell.count > 0 && indexPath.row < self.resultCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.currentResult[indexPath.row] as! NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.resultCell.count > 0 && indexPath.row < self.resultCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.currentResult[indexPath.row] as! NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cTweetData = self.currentResult[indexPath.row] as! NSDictionary
        var detailView = TweetDetailViewController(
            aTweetID: cTweetData.objectForKey("id_str") as! String,
            aTweetBody: cTweetData.objectForKey("text") as! String,
            aScreenName: cTweetData.objectForKey("user")?.objectForKey("screen_name") as! String,
            aUserName: cTweetData.objectForKey("user")?.objectForKey("name") as! String,
            aProfileImage: cTweetData.objectForKey("user")?.objectForKey("profile_image_url") as! String,
            aPostDetail: cTweetData.objectForKey("created_at") as! String,
            aRetweetedName: nil,
            aRetweetedProfileImage: nil,
            aFavorited: cTweetData.objectForKey("favorited?") as? Bool,
            aMedia: cTweetData.objectForKey("media") as? NSArray,
            aParentArray: &self.currentResult,
            aParentIndex: indexPath.row,
            aProtected: cTweetData.objectForKey("user")?.objectForKey("protected") as? Bool
        )
        self.navigationController!.pushViewController(detailView, animated: true)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
   
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.tweetSearchBar.showsCancelButton = true
        for childView in searchBar.subviews {
            for subView in childView.subviews {
                if (subView.isKindOfClass(UIButton.classForCoder())){
                    let cancelButton = subView as! UIButton
                    cancelButton.setTitle("キャンセル", forState: .Normal)
                }
            }
        }
        self.tweetSearchBar.autocorrectionType = UITextAutocorrectionType.No
        self.navigationItem.rightBarButtonItem = nil
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        self.navigationItem.rightBarButtonItem = self.saveButton
        self.tweetSearchBar.showsCancelButton = false
        return true
    }

   
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var params: Dictionary<String, String> = [
            "count" : String(self.tweetCount)
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params,
            "q" : self.tweetSearchBar.text
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/search.json", params: cParameter) { (aNewResult) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, { () -> Void in
                self.newResult = []
                for timeline in aNewResult {
                    var mutableTimeline = timeline.mutableCopy() as! NSMutableDictionary
                    self.newResult.append(mutableTimeline)
                }
                if (self.newResult.count > 0) {
                    for newResult in self.newResult {
                        self.currentResult.insert(newResult, atIndex: 0)
                    }
                    self.tableView.reloadData()
                }
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(aNewResult.count) + "件")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
                self.tweetSearchBar.resignFirstResponder()
            })
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.tweetSearchBar.resignFirstResponder()
    }
    
    func saveResult() {
        if (count(self.tweetSearchBar.text) > 0) {
            var searchStream = ListTableViewController.Stream(
                image: "",
                name: self.tweetSearchBar.text,
                type: "search",
                uri: "users/apis/search.json",
                id: "")
            let cViewControllers = self.navigationController!.viewControllers as NSArray
            let cViewControllersCount = cViewControllers.count as Int
            let cParentController: ListTableViewController = cViewControllers.objectAtIndex(cViewControllersCount - 2) as! ListTableViewController
            cParentController.streamList.append(searchStream)
            self.navigationController!.popViewControllerAnimated(true)
        }
    }

}
