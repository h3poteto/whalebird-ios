//
//  WebViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/12/06.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD
import Reachability
import NoticeView

class WebViewController: UIViewController, UIWebViewDelegate {

    //=============================================
    //  instance variables
    //=============================================
    var webView: UIWebView!
    var openURL: String!
    var whalebirdURL = Bundle.main.object(forInfoDictionaryKey: "weburl") as! String

    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
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
        self.webView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.webView.delegate = self
        if Reachability()!.isReachable {
            if let requestURL = URL(string: self.whalebirdURL + self.openURL) {
                self.webView.loadRequest(URLRequest(url: requestURL))
            }
             self.view.addSubview(self.webView)
        } else {
            let notice = WBErrorNoticeView.errorNotice(in: UIApplication.shared.delegate?.window!, title: NSLocalizedString("NetworkErrorTitle", tableName: "WebView", comment: ""), message: NSLocalizedString("NetworkErrorMessage", tableName: "WebView", comment: ""))
            notice?.alpha = 0.8
            notice?.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
            notice?.show()
        }
       
        // Do any additional setup after loading the view.
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
}
