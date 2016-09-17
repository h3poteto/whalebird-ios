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
    var resultCell: Array<TimelineViewCell> = []
    var timelineModel: TimelineModel!


    //=============================================
    //  instance methods
    //=============================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.prepareTableView()
    }

    override func loadView() {
        super.loadView()
        self.prepareSearchBar()
    }

    func prepareSearchBar() {
        self.tweetSearchBar = UISearchBar()
        self.tweetSearchBar.placeholder = "ツイート検索"
        self.tweetSearchBar.keyboardType = UIKeyboardType.default
        self.tweetSearchBar.delegate = self

        self.navigationItem.titleView = self.tweetSearchBar
        self.tweetSearchBar.becomeFirstResponder()
    }

    func prepareTableView() {
        self.timelineModel = TimelineModel(initSinceId: nil, initTimeline: nil)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.timelineModel.count()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCell(withIdentifier: "TimelineViewCell", for: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "TimelineViewCell")
        }
        
        self.resultCell.insert(cell!, at: (indexPath as NSIndexPath).row)

        cell!.cleanCell()
        if let targetResult = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            cell!.configureCell(targetResult as NSDictionary)
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetResult = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            height = TimelineViewCell.estimateCellHeight(targetResult as NSDictionary)
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetResult = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            height = TimelineViewCell.estimateCellHeight(targetResult as NSDictionary)
        }
        return height
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cTweetData = self.timelineModel.getTweetAtIndex((indexPath as NSIndexPath).row) {
            let tweetModel = TweetModel(dict: cTweetData)
            let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: (indexPath as NSIndexPath).row)
            self.navigationController?.pushViewController(detailView, animated: true)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
   
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        self.tweetSearchBar.showsCancelButton = true
        self.tweetSearchBar.autocorrectionType = UITextAutocorrectionType.no
        self.navigationItem.rightBarButtonItem = nil
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.tweetSearchBar.showsCancelButton = false
        return true
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.executeSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tweetSearchBar.resignFirstResponder()
    }
    
    func executeSearch() {
        guard self.tweetSearchBar.text != nil else {
            return
        }
        let params: Dictionary<String, String> = [
            "count" : String(self.timelineModel.tweetCount)
        ]
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params as AnyObject,
            "q" : self.tweetSearchBar.text! as AnyObject
        ]
        SVProgressHUD.show(withStatus: "キャンセル", maskType: SVProgressHUDMaskType.clear)
        self.timelineModel.updateTimelineWitoutMoreAndSince("users/apis/search.json", requestParameter: cParameter,
            completed: { (count, currentRowIndex) -> Void in
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                let notice = WBSuccessNoticeView.successNotice(in: self.navigationController!.view, title: String(count) + "件")
                notice?.alpha = 0.8
                notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice?.show()
                self.tweetSearchBar.resignFirstResponder()
            }, noUpdated: { () -> Void in
                
            }, failed: { () -> Void in
                
        })
    }
}
