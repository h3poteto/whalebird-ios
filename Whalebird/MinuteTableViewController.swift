//
//  MinuteTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/13.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

protocol MinuteTableViewControllerDelegate {
    func rewriteTweetWithMinute(_ minute: NSDictionary, index: Int)
}

class MinuteTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var minuteModel: MinuteModel!
    var delegate: MinuteTableViewControllerDelegate!
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.minuteModel = MinuteModel()     
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    convenience init() {
        self.init(style: UITableViewStyle.plain)
        self.minuteModel = MinuteModel()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.editButtonItem.title = "編集"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if(self.isEditing){
            self.editButtonItem.title = "完了"
        }else{
            self.editButtonItem.title = "編集"
        }
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
        return self.minuteModel.count()
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "MinuteCell")
        if let minute = self.minuteModel.getMinuteAtIndex((indexPath as NSIndexPath).row) {
            cell.textLabel?.text = minute.object(forKey: "text") as? String
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let minute = self.minuteModel.getMinuteAtIndex((indexPath as NSIndexPath).row) {
            self.delegate.rewriteTweetWithMinute(minute, index: (indexPath as NSIndexPath).row)
            self.navigationController?.popViewController(animated: true)
        }
    }


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.minuteModel.removeAtIndexAndSaveList((indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // 配列の先頭に下書きを追加して，NSUserDefaultにも保存
    func addMinute(_ minuteString: String!, minuteReplyToID: String?) {
        self.minuteModel.addMinuteAtFirst(minuteString, replyToID: minuteReplyToID)
    }
    
    func deleteMinute(_ index: Int!) {
        self.minuteModel.deleteMinuteAtIndex(index)
    }

}
