//
//  LoginViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/10/30.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ExWebView: UIWebView {
    override func loadRequest(request: NSURLRequest) {
        var mRequest = request.mutableCopy() as NSMutableURLRequest
        mRequest.setValue(ApplicationSecrets.Secret(), forHTTPHeaderField: "Whalebird-Key")
        super.loadRequest(mRequest)
    }
}

class LoginViewController: UIViewController, UIWebViewDelegate {
    var loginWebView: UIWebView!
    var redirectedTwitter: Bool = false
    var whalebirdAPIURL: NSURL = NSURL(string: NSBundle.mainBundle().objectForInfoDictionaryKey("apiurl") as String)!
    var whalebirdAPIWithKey: String = (NSBundle.mainBundle().objectForInfoDictionaryKey("apiurl") as String) + "users/sign_in?"

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

        self.loginWebView = ExWebView(frame: self.view.frame)
        self.loginWebView.scalesPageToFit = true
        self.loginWebView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.loginWebView.delegate = self
        var request = NSMutableURLRequest(URL: NSURL(string: self.whalebirdAPIWithKey)!)
        self.loginWebView.loadRequest(request)
        self.view.addSubview(self.loginWebView)
        // SVProgressHUDの表示スタイル設定
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hudTapped", name: SVProgressHUDDidReceiveTouchEventNotification, object: nil)
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
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (self.redirectedTwitter && request.URL.host == self.whalebirdAPIURL.host && (request.URL.absoluteString as NSString!).rangeOfString("callback").location == NSNotFound) {
            WhalebirdAPIClient.sharedClient.initAPISession()
            
            var index = self.navigationController!.viewControllers.count
            var parent = (self.navigationController!.viewControllers as NSArray).objectAtIndex(index - 2) as SettingsTableViewController
            parent.syncWhalebirdServer()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.navigationController!.popViewControllerAnimated(true)
            return false
        } else if ((request.URL.absoluteString as NSString!).rangeOfString("api.twitter.com").location != NSNotFound) {
            self.redirectedTwitter = true
        }
        return true
    }
    
    func hudTapped() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.loginWebView.stopLoading()
    }

}
