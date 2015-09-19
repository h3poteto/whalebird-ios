//
//  SearchTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/12/10.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD
import NoticeView

class SearchTableViewController: UITableViewController, UISearchBarDelegate {

    //=============================================
    //  instance variables
    //=============================================
    var tweetSearchBar: UISearchBar!
    var resultCell: Array<AnyObject> = []
    var saveButton: UIBarButtonItem!
    var timelineModel: TimelineModel!
    var streamList: StreamList?
    var searchKeyword: String?

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
    
    convenience init(aStreamList: StreamList) {
        self.init()
        self.streamList = aStreamList
    }
    
    convenience init(aStreamList: StreamList, keyword: String) {
        self.init(aStreamList: aStreamList)
        self.searchKeyword = keyword
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = UIScreen.mainScreen().bounds
        self.tweetSearchBar = UISearchBar()
        self.tweetSearchBar.placeholder = "検索"
        self.tweetSearchBar.keyboardType = UIKeyboardType.Default
        self.tweetSearchBar.delegate = self
        
        self.navigationItem.titleView = self.tweetSearchBar
        self.tweetSearchBar.becomeFirstResponder()
        
        self.saveButton = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: "saveResult")
        
        self.timelineModel = TimelineModel(initSinceId: nil, initTimeline: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        if self.searchKeyword != nil {
            self.tweetSearchBar.text = self.searchKeyword!
            self.executeSearch()
        }
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
        return self.timelineModel.count()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
        }
        
        self.resultCell.insert(cell!, atIndex: indexPath.row)

        cell!.cleanCell()
        if let targetResult = self.timelineModel.getTweetAtIndex(indexPath.row) {
            cell!.configureCell(targetResult)
        }

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetResult = self.timelineModel.getTweetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetResult)
        }
        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetResult = self.timelineModel.getTweetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetResult)
        }
        return height
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cTweetData = self.timelineModel.getTweetAtIndex(indexPath.row) {
            let tweetModel = TweetModel(dict: cTweetData)
            let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: indexPath.row)
            self.navigationController?.pushViewController(detailView, animated: true)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
   
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        self.tweetSearchBar.showsCancelButton = true
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
        self.executeSearch()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.tweetSearchBar.resignFirstResponder()
    }
    
    func executeSearch() {
        let params: Dictionary<String, String> = [
            "count" : String(self.timelineModel.tweetCount)
        ]
        let cParameter: Dictionary<String, Any> = [
            "settings" : params,
            "q" : self.tweetSearchBar.text
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        self.timelineModel.updateTimelineWitoutMoreAndSince("users/apis/search.json", requestParameter: cParameter as! Dictionary<String, AnyObject>,
            completed: { (count, currentRowIndex) -> Void in
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                let notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(count) + "件")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
                self.tweetSearchBar.resignFirstResponder()
            }, noUpdated: { () -> Void in
                
            }, failed: { () -> Void in
                
        })
    }
    
    func saveResult() {
        if (self.tweetSearchBar.text!.characters.count > 0) {
            self.streamList?.addNewStream(
                "",
                name: self.tweetSearchBar.text!,
                type: "search",
                uri: "users/apis/search.json",
                id: ""
            )
            self.navigationController!.popViewControllerAnimated(true)
        }
    }

}
