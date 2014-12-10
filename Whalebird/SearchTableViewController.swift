//
//  SearchTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/12/10.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var tweetCount = Int(50)
    var searchBar: UISearchBar!
    var currentResult: Array<AnyObject> = []
    var newResult: Array<AnyObject> = []
    var resultCell: Array<AnyObject> = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let window = UIScreen.mainScreen().bounds
        self.searchBar = UISearchBar()
        self.searchBar.placeholder = "検索"
        self.searchBar.keyboardType = UIKeyboardType.Default
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        
        self.navigationItem.titleView = self.searchBar
        self.searchBar.becomeFirstResponder()
        
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
        cell!.configureCell(self.currentResult[indexPath.row] as NSDictionary)
        // Configure the cell...

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.resultCell.count > 0 && indexPath.row < self.resultCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.currentResult[indexPath.row] as NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.resultCell.count > 0 && indexPath.row < self.resultCell.count) {
            height = TimelineViewCell.estimateCellHeight(self.currentResult[indexPath.row] as NSDictionary)
        } else {
            height = 60.0
        }
        return height
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cTweetData = self.currentResult[indexPath.row] as NSDictionary
        var detailView = TweetDetailViewController(
            aTweetID: cTweetData.objectForKey("id_str") as String,
            aTweetBody: cTweetData.objectForKey("text") as String,
            aScreenName: cTweetData.objectForKey("user")?.objectForKey("screen_name") as String,
            aUserName: cTweetData.objectForKey("user")?.objectForKey("name") as String,
            aProfileImage: cTweetData.objectForKey("user")?.objectForKey("profile_image_url") as String,
            aPostDetail: cTweetData.objectForKey("created_at") as String,
            aRetweetedName: nil,
            aRetweetedProfileImage: nil
        )
        self.navigationController!.pushViewController(detailView, animated: true)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var params: Dictionary<String, String> = [:]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params,
            "q" : self.searchBar.text
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: UInt(SVProgressHUDMaskTypeClear))
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/search.json", params: cParameter) { (aNewResult) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, { () -> Void in
                self.newResult = aNewResult
                if (self.newResult.count > 0) {
                    for newResult in self.newResult {
                        self.currentResult.insert(newResult, atIndex: 0)
                    }
                    self.tableView.reloadData()
                }
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(aNewResult.count) + "件")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.searchBar.resignFirstResponder()
            })
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

}
