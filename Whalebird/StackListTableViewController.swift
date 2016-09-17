//
//  StackListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol StackListTableViewControllerDelegate {
    func decidedStackStreamList(_ stackStreamList: StreamList)
}

class StackListTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var twitterScreenName: String?
    var stackStreamList: StreamList!
    
    var delegate: StackListTableViewControllerDelegate!

    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.title = "リストを選択"
        let userDefault = UserDefaults.standard
        self.twitterScreenName = userDefault.object(forKey: "username") as? String
    }
    
    convenience init() {
        self.init(style: UITableViewStyle.plain)
        self.stackStreamList = StreamList()
        self.stackStreamList.initStreamList()
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        let selectButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.done, target: self, action: #selector(StackListTableViewController.decideSelected(_:)))
        self.navigationItem.rightBarButtonItem = selectButton
        
        self.tableView.allowsMultipleSelection = true
        
        
        if (self.twitterScreenName != nil) {
            let params: Dictionary<String, String> = [
                "screen_name" : self.twitterScreenName!
            ]
            let cParameter: Dictionary<String, AnyObject> = [
                "settings" : params as AnyObject
            ]
            SVProgressHUD.show(withStatus: "キャンセル", maskType: SVProgressHUDMaskType.clear)
            WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/lists.json", displayError: true, params: cParameter,
                completed: { (aStackList) -> Void in
                    let q_main = DispatchQueue.main
                    print(aStackList)
                    q_main.async(execute: {()->Void in
                        for list in aStackList {
                            self.stackStreamList.addNewStream(
                                "",
                                name: list.object(forKey: "full_name") as! String,
                                type: "list",
                                uri: list.object(forKey: "uri") as! String,
                                id: list.object(forKey: "id_str") as! String
                            )
                        }
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    })
                }, failed: { () -> Void in
                }
            )
        }

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
        return self.stackStreamList.count()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.stackStreamList.getStreamAtIndex((indexPath as NSIndexPath).row).name
        cell.textLabel?.font = UIFont(name: TimelineViewCell.NormalFont, size: 16)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.none
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func decideSelected(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
        if let selectedArray = self.tableView.indexPathsForSelectedRows as Array? {
            if (selectedArray.count > 0) {
                let selectedStreamList = StreamList()
                selectedStreamList.initWithEmpty()
                for index in selectedArray {
                    selectedStreamList.add(self.stackStreamList.getStreamAtIndex((index as NSIndexPath).row))
                }
                self.delegate.decidedStackStreamList(selectedStreamList)
            }
        }
        // ListTableViewをアップデートする
    }
}
