//
//  NewTweetViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let optionItemBarHeight = CGFloat(40)
    let imageViewSpan = CGFloat(20)
    
    var maxSize: CGSize!
    var tweetBody: String!
    var replyToID: String?
    
    var newTweetText: UITextView!
    var cancelButton: UIBarButtonItem!
    var sendButton: UIBarButtonItem!
    var photostreamButton: UIBarButtonItem?
    var cameraButton: UIBarButtonItem?
    var optionItemBar: UIToolbar?
    var currentCharacters: Int = 140
    var uploadImageView: UIImageView?
    var closeImageView: UIButton!
    var uploadedImage: String?
    var progressCount = Int(0)
    
    //======================================
    //  instance method
    //======================================
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "ツイート送信"
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    init(aTweetBody: String!, aReplyToID: String?) {
        super.init()
        self.tweetBody = aTweetBody
        self.replyToID = aReplyToID
    }
    
    override func loadView() {
        super.loadView()
    }
    
    // TODO: 入力可能文字列カウント
    override func viewDidLoad() {
        super.viewDidLoad()
        let cWindowSize = UIScreen.mainScreen().bounds
        self.maxSize = cWindowSize.size
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "onCancelTapped")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        sendButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onSendTapped")
        self.navigationItem.rightBarButtonItem = sendButton
        
        newTweetText = UITextView(frame: CGRectMake(0, 0, self.maxSize.width, self.maxSize.height / 2.0))
        newTweetText.editable = true
        newTweetText.delegate = self
        newTweetText.font = UIFont.systemFontOfSize(18)
        self.view.addSubview(newTweetText)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        newTweetText.keyboardAppearance = UIKeyboardAppearance.Light
        newTweetText.text = self.tweetBody
        newTweetText.becomeFirstResponder()
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
        var windowSize = UIScreen.mainScreen().bounds.size
        var info = notification.userInfo as NSDictionary?
        if (info != nil) {
            var keyboardSize = info!.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue() as CGRect?
            self.optionItemBar = UIToolbar(frame: CGRectMake(0, keyboardSize!.origin.y - self.optionItemBarHeight, windowSize.width, self.optionItemBarHeight))
            self.optionItemBar?.backgroundColor = UIColor.lightGrayColor()
            // 配置するボタン
            var spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            self.photostreamButton = UIBarButtonItem(image: UIImage(named: "Image.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "openPhotostream")
            self.cameraButton = UIBarButtonItem(image: UIImage(named: "Camera-Line.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "openCamera")
            
            var itemArray = [spacer, self.photostreamButton!, spacer, self.cameraButton!, spacer]
            self.optionItemBar?.setItems(itemArray, animated: true)
            
            self.view.addSubview(self.optionItemBar!)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.optionItemBar != nil) {
            self.optionItemBar?.removeFromSuperview()
        }
    }
    
    func onCancelTapped() {
        self.newTweetText.text = ""
        self.navigationController!.popViewControllerAnimated(true)
        
    }
    
    func openPhotostream() {
        let ipc:UIImagePickerController = UIImagePickerController();
        ipc.delegate = self
        ipc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(ipc, animated:true, completion:nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            //camera ok
            let ipc:UIImagePickerController = UIImagePickerController();
            ipc.delegate = self
            ipc.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(ipc, animated:true, completion:nil)
            
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if (info[UIImagePickerControllerOriginalImage] != nil) {
            let image:UIImage = info[UIImagePickerControllerOriginalImage]  as UIImage
            self.uploadImageView = UIImageView(frame: CGRectMake(self.imageViewSpan, self.optionItemBar!.frame.origin.y - self.optionItemBarHeight * 2, 50, 50))
            self.uploadImageView?.image = image
            var width: CGFloat
            var height: CGFloat
            if (image.size.width > image.size.height) {
                width = CGFloat(50.0)
                height = CGFloat(50.0 * image.size.height / image.size.width)
            } else {
                width = CGFloat(50.0 * image.size.width / image.size.height)
                height = CGFloat(50.0)

            }
            self.uploadImageView?.sizeThatFits(CGSize(width: width, height: height))
            self.view.addSubview(self.uploadImageView!)
            
            self.closeImageView = UIButton(frame: CGRectMake(self.uploadImageView!.frame.origin.x + self.uploadImageView!.frame.width, self.uploadImageView!.frame.origin.y - 20, 20.0, 20.0))
            self.closeImageView.setImage(UIImage(named: "Close-Filled.png"), forState: UIControlState.Normal)
            self.closeImageView.addTarget(self, action: "removeImage", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(self.closeImageView)
            
            // upload処理
            // Whalebirdのapiにupload
            // ファイルパスだけ戻してもらってpostのparameterに付随させてtweet判定
            // TODO: プログレスバーの表示
            WhalebirdAPIClient.sharedClient.postImage(image, progress: { (written) -> Void in
                self.progressCount = Int(written * 100)
                println(self.progressCount)
                
            }, callback: { (response) -> Void in
                println(response)
                self.uploadedImage = (response as NSDictionary).objectForKey("filename") as? String
            })

        }
        //allowsEditingがtrueの場合 UIImagePickerControllerEditedImage
        //閉じる処理
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    func removeImage() {
        if (self.uploadImageView != nil) {
            self.uploadImageView!.removeFromSuperview()
            self.uploadImageView = nil
        }
        self.closeImageView.removeFromSuperview()
        self.uploadedImage = nil
    }
    
    //-----------------------------------------
    //  送信ボタンを押した時の処理
    //-----------------------------------------
    func onSendTapped() {
        if (countElements(newTweetText.text as String) > 0) {
            postTweet(newTweetText.text)
        }
    }
    
    
    //-----------------------------------------
    //-----------------------------------------
    func postTweet(aTweetBody: NSString) {
        var params: Dictionary<String, String> = [:]
        var parameter: Dictionary<String, AnyObject> = [
            "status" : newTweetText.text
        ]
        if (self.replyToID != nil) {
            params["in_reply_to_status_id"] = self.replyToID!
        }
        if (self.uploadedImage != nil) {
            params["media"] = self.uploadedImage!
        }
        
        if (params.count != 0) {
            parameter["settings"] = params
        }
        SVProgressHUD.showWithStatus("キャンセル", maskType: UInt(SVProgressHUDMaskTypeClear))
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/tweet.json", params: parameter) { (aOperation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var notice = WBSuccessNoticeView.successNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "投稿しました")
                SVProgressHUD.dismiss()
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }


}
