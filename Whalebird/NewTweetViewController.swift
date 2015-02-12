//
//  NewTweetViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

// TODO: 書き換えの項目を下書き保存する機能を追加
class NewTweetViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let optionItemBarHeight = CGFloat(40)
    let imageViewSpan = CGFloat(20)
    let progressColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
    
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
    var currentCharactersView: UIBarButtonItem?
    var uploadImageView: UIImageView?
    var closeImageView: UIButton!
    var uploadedImage: String?
    var progressCount = Int(0)
    

    // 右上は送信
    // アラートは敬語
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
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cWindowSize = UIScreen.mainScreen().bounds
        self.maxSize = cWindowSize.size
        
        self.cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.Plain, target: self, action: "onCancelTapped")
        self.navigationItem.leftBarButtonItem = self.cancelButton
        
        self.sendButton = UIBarButtonItem(title: "送信", style: UIBarButtonItemStyle.Done, target: self, action: "onSendTapped")
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.newTweetText = UITextView(frame: CGRectMake(0, 0, self.maxSize.width, self.maxSize.height / 2.0))
        self.newTweetText.editable = true
        self.newTweetText.delegate = self
        self.newTweetText.font = UIFont(name: TimelineViewCell.NormalFont, size: 18)
        self.view.addSubview(self.newTweetText)
        
        self.newTweetText.keyboardAppearance = UIKeyboardAppearance.Light
        self.newTweetText.text = self.tweetBody
        self.newTweetText.becomeFirstResponder()
        self.currentCharacters = 140 - self.newTweetText.text.utf16Count
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.currentCharacters = 140 - (textView.text.utf16Count - range.length + text.utf16Count)
        if (self.currentCharactersView != nil) {
            self.currentCharactersView?.title = String(self.currentCharacters)
        }
        return true
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
        var windowSize = UIScreen.mainScreen().bounds.size
        var info = notification.userInfo as NSDictionary?
        if (info != nil) {
            self.optionItemBar?.removeFromSuperview()
            var keyboardSize = info!.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue() as CGRect?
            self.optionItemBar = UIToolbar(frame: CGRectMake(0, keyboardSize!.origin.y - self.optionItemBarHeight, windowSize.width, self.optionItemBarHeight))
            self.optionItemBar?.backgroundColor = UIColor.lightGrayColor()
            // 配置するボタン
            var spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            self.photostreamButton = UIBarButtonItem(image: UIImage(named: "Image.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "openPhotostream")
            self.cameraButton = UIBarButtonItem(image: UIImage(named: "Camera-Line.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "openCamera")
            self.currentCharactersView = UIBarButtonItem(title: String(self.currentCharacters), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            
            var itemArray = [spacer, self.photostreamButton!, spacer, self.cameraButton!, spacer, self.currentCharactersView!]
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
            // カメラで撮影するだけでは保存はされていない
            if (picker.sourceType == UIImagePickerControllerSourceType.Camera) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
            // アス比を固定したままリサイズ
            var sendWidth = CGFloat(image.size.width)
            var sendHeight = CGFloat(image.size.height)
            var width = CGFloat(image.size.width)
            var height = CGFloat(image.size.height)
            if (image.size.width > image.size.height) {
                width = CGFloat(50.0)
                height = CGFloat(50.0 * image.size.height / image.size.width)
                sendWidth = CGFloat(800.0)
                sendHeight = CGFloat(800.0 * image.size.height / image.size.width)
            } else {
                width = CGFloat(50.0 * image.size.width / image.size.height)
                height = CGFloat(50.0)
                sendWidth = CGFloat(800.0 * image.size.width / image.size.height)
                sendHeight = CGFloat(800.0)

            }
            
            var resizedImage = self.resizeImage(image, newSize: CGSize(width: sendWidth, height: sendHeight))
            
            self.uploadImageView?.sizeThatFits(CGSize(width: width, height: height))
            self.uploadImageView = UIImageView(frame: CGRectMake(self.imageViewSpan, self.optionItemBar!.frame.origin.y - self.optionItemBarHeight * 2, width, height))
            self.uploadImageView?.image = resizedImage
            self.view.addSubview(self.uploadImageView!)
            
            var progressView = DACircularProgressView(frame: CGRectMake(0, 0, width * 2.0 / 3.0, height * 2.0 / 3.0))
            progressView.center = CGPoint(x: width / 2.0, y: height / 2.0)
            progressView.roundedCorners = 0
            progressView.progressTintColor = self.progressColor
            progressView.trackTintColor = UIColor.grayColor()
            progressView.setProgress(0.0, animated: true)
            self.uploadImageView!.addSubview(progressView)
            
            self.closeImageView = UIButton(frame: CGRectMake(self.uploadImageView!.frame.origin.x + self.uploadImageView!.frame.width, self.uploadImageView!.frame.origin.y - 20, 20.0, 20.0))
            self.closeImageView.setImage(UIImage(named: "Close-Filled.png"), forState: UIControlState.Normal)
            self.closeImageView.addTarget(self, action: "removeImage", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(self.closeImageView)
            
            // upload処理
            // Whalebirdのapiにupload
            // ファイルパスだけ戻してもらってpostのparameterに付随させてtweet判定
            WhalebirdAPIClient.sharedClient.postImage(resizedImage, progress: { (written) -> Void in
                self.progressCount = Int(written * 100)
                println(self.progressCount)
                progressView.setProgress(CGFloat(written), animated: true)
                
            }, callback: { (response) -> Void in
                println(response)
                self.uploadedImage = (response as NSDictionary).objectForKey("filename") as? String
                progressView.removeFromSuperview()
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
        WhalebirdAPIClient.sharedClient.cancelRequest()
    }
    
    //-----------------------------------------
    //  送信ボタンを押した時の処理
    //-----------------------------------------
    func onSendTapped() -> Bool {
        if (self.uploadImageView != nil) {
            if (self.uploadedImage == nil) {
                var alertController = UIAlertController(title: "画像アップロード中です", message: "アップロード後にもう一度送信してください", preferredStyle: .Alert)
                let cOkAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                })
                alertController.addAction(cOkAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return false
            }
        }
        if (countElements(newTweetText.text as String) > 0) {
            postTweet(newTweetText.text)
            return true
        }
        return false
    }
    
    
    //-----------------------------------------
    //  whalebirdにPOST
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
                notice.originY = (UIApplication.sharedApplication().delegate as AppDelegate).alertPosition
                notice.show()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    //-----------------------------------------------
    //  resizeには軽さを求めるのでCoreGraphicsを使う
    //-----------------------------------------------
    func resizeImage(srcImage: UIImage, newSize: CGSize) -> UIImage {
        let targetWidth = newSize.width
        let targetHeight = newSize.height
        
        let imageRef = srcImage.CGImage as CGImageRef
        let bitmapInfo = CGImageGetBitmapInfo(imageRef) as CGBitmapInfo
        let colorSpaceInfo = CGImageGetColorSpace(imageRef) as CGColorSpaceRef
        
        var bitmap: CGContextRef!
        bitmap = CGBitmapContextCreate(nil, UInt(targetWidth), UInt(targetHeight), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo)
        /*
        if (srcImage.imageOrientation == UIImageOrientation.Up || srcImage.imageOrientation == UIImageOrientation.Down) {
            bitmap = CGBitmapContextCreate(nil, UInt(targetWidth), UInt(targetHeight), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo)
        } else {
            bitmap = CGBitmapContextCreate(nil, UInt(targetHeight), UInt(targetWidth), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo)
        }*/
        
        if (srcImage.imageOrientation == UIImageOrientation.Left) {
            CGContextRotateCTM(bitmap, self.radian(90))
            CGContextTranslateCTM(bitmap, 0, -targetWidth)
            CGContextScaleCTM(bitmap, srcImage.size.height / srcImage.size.width, srcImage.size.width / srcImage.size.height)
        } else if (srcImage.imageOrientation == UIImageOrientation.Right) {
            CGContextRotateCTM(bitmap, self.radian(-90))
            CGContextTranslateCTM(bitmap, -targetHeight, 0)
            CGContextScaleCTM(bitmap, srcImage.size.height / srcImage.size.width, srcImage.size.width / srcImage.size.height)
        } else if (srcImage.imageOrientation == UIImageOrientation.Up) {
            
        } else if (srcImage.imageOrientation == UIImageOrientation.Down) {
            CGContextTranslateCTM(bitmap, targetWidth, targetHeight)
            CGContextRotateCTM(bitmap, self.radian(-180))
        }
        
        CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef)
        var ref = CGBitmapContextCreateImage(bitmap)
        var newImage = UIImage(CGImage: ref) as UIImage!
        
        return newImage
        
    }


    func radian(degree: Float) -> CGFloat {
        return CGFloat(degree * 3.14159265358979323846 / 180.0)
    }
}
