//
//  LoginViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/10/30.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD
import ReachabilitySwift
import NoticeView

class ExWebView: UIWebView {
    override func loadRequest(_ request: URLRequest) {
        if let mRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
            mRequest.setValue(ApplicationSecrets.Secret(), forHTTPHeaderField: "Whalebird-Key")
            super.loadRequest(mRequest as URLRequest)
        }
    }
}

class LoginViewController: UIViewController, UIWebViewDelegate {

    //=============================================
    //  instance variables
    //=============================================
    var loginWebView: UIWebView!
    var redirectedTwitter: Bool = false
    var whalebirdAPIURL: URL = URL(string: Bundle.main.object(forInfoDictionaryKey: "apiurl") as! String)!
    var whalebirdAPIWithKey: String = (Bundle.main.object(forInfoDictionaryKey: "apiurl") as! String) + "users/sign_in?"

    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = NSLocalizedString("Title", tableName: "Login", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginWebView = ExWebView(frame: self.view.frame)
        self.loginWebView.scalesPageToFit = true
        self.loginWebView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.loginWebView.delegate = self
        let request = NSMutableURLRequest(url: URL(string: self.whalebirdAPIWithKey)!)
        if Reachability()!.isReachable {
            self.loginWebView.loadRequest(request as URLRequest)
            self.view.addSubview(self.loginWebView)
        } else {
            let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: NSLocalizedString("NetworkErrorTitle", tableName: "Login", comment: ""), message: NSLocalizedString("NetworkErrorMessage", tableName: "Login", comment: ""))
            notice?.alpha = 0.8
            notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
            notice?.show()
        }
        // SVProgressHUDの表示スタイル設定
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.hudTapped), name: NSNotification.Name.SVProgressHUDDidReceiveTouchEvent, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (self.redirectedTwitter && request.url!.host == self.whalebirdAPIURL.host && (request.url!.absoluteString as NSString!).range(of: "callback").location == NSNotFound) {
            WhalebirdAPIClient.sharedClient.initAPISession({ () -> Void in
                SVProgressHUD.show(withStatus: NSLocalizedString("Cancel", comment: ""), maskType: SVProgressHUDMaskType.clear)
                WhalebirdAPIClient.sharedClient.syncPushSettings({ (result) -> Void in
                    SVProgressHUD.dismiss()
                })
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                _ = self.navigationController?.popViewController(animated: true)
            }, failure: { (error) -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false                
            })
            return false
        } else if ((request.url!.absoluteString as NSString!).range(of: "api.twitter.com").location != NSNotFound) {
            self.redirectedTwitter = true
        }
        return true
    }
    
    @objc func hudTapped() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.loginWebView.stopLoading()
    }

}
