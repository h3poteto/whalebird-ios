//
//  LoginViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/10/30.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {
    var loginWebView: UIWebView!
    var redirectedTwitter: Bool = false
    var whalebirdAPIURL: NSURL = NSURL(string: NSBundle.mainBundle().objectForInfoDictionaryKey("apiurl") as String)!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "ログイン"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginWebView = UIWebView(frame: self.view.frame)
        self.loginWebView.scalesPageToFit = true
        self.loginWebView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.loginWebView.delegate = self
        self.loginWebView.loadRequest(NSURLRequest(URL: self.whalebirdAPIURL))
        self.view.addSubview(self.loginWebView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        println(request)
        if (self.redirectedTwitter && request.URL.host == self.whalebirdAPIURL.host && (request.URL.absoluteString as NSString!).rangeOfString("callback").location == NSNotFound) {
            WhalebirdAPIClient.sharedClient.initAPISession()
            
            var index = self.navigationController!.viewControllers.count
            var parent = (self.navigationController!.viewControllers as NSArray).objectAtIndex(index - 2) as SettingsTableViewController
            parent.syncWhalebirdServer()
            self.navigationController!.popViewControllerAnimated(true)
            return false
        } else if ((request.URL.absoluteString as NSString!).rangeOfString("api.twitter.com").location != NSNotFound) {
            self.redirectedTwitter = true
        }
        return true
    }

}
