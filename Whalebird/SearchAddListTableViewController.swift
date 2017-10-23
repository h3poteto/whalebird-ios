//
//  SearchAddListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2016/09/17.
//  Copyright © 2016年 AkiraFukushima. All rights reserved.
//

import UIKit

class SearchAddListTableViewController: SearchTableViewController {
    var saveButton: UIBarButtonItem!    
    var streamList: StreamList?
    var searchKeyword: String?

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

        self.prepareSearchBar()
        self.saveButton = UIBarButtonItem(title: NSLocalizedString("Save", tableName: "Search", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SearchAddListTableViewController.saveResult))

        if self.searchKeyword != nil {
            self.tweetSearchBar.text = self.searchKeyword!
            self.executeSearch()
        }

    }

    override func prepareSearchBar() {
        self.tweetSearchBar = UISearchBar()
        self.tweetSearchBar.placeholder = NSLocalizedString("SearchBar", tableName: "Search", comment: "")
        self.tweetSearchBar.keyboardType = UIKeyboardType.default
        self.tweetSearchBar.delegate = self

        self.navigationItem.titleView = self.tweetSearchBar
        self.tweetSearchBar.becomeFirstResponder()
    }


    @objc func saveResult() {
        if (self.tweetSearchBar.text!.characters.count > 0) {
            self.streamList?.addNewStream(
                "",
                name: self.tweetSearchBar.text!,
                type: "search",
                uri: "users/apis/search.json",
                id: ""
            )
            self.navigationController!.popViewController(animated: true)
        }
    }

    override func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {

        self.tweetSearchBar.showsCancelButton = true
        self.tweetSearchBar.autocorrectionType = UITextAutocorrectionType.no
        self.navigationItem.rightBarButtonItem = nil
        return true
    }

    override func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.navigationItem.rightBarButtonItem = self.saveButton
        self.tweetSearchBar.showsCancelButton = false
        return true
    }


    override func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.executeSearch()
    }

    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tweetSearchBar.resignFirstResponder()
    }
}
