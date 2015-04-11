//
//  WebViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/12/06.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    var webView: UIWebView!
    var openURL: String!
    var whalebirdURL = NSBundle.mainBundle().objectForInfoDictionaryKey("weburl") as! String
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    convenience init(aOpenURL: String, aTitle: String) {
        self.init()
        self.openURL = aOpenURL
        self.title = aTitle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView = UIWebView(frame: self.view.frame)
        self.webView.scalesPageToFit = true
        self.webView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.whalebirdURL + self.openURL)!))
        self.view.addSubview(self.webView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
    }
}
