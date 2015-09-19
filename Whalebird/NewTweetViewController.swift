//
//  NewTweetViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import DACircularProgress
import SVProgressHUD
import NoticeView

class NewTweetViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditImageViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MinuteTableViewControllerDelegate {

    //=============================================
    //  instance variables
    //=============================================
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
    var minuteButton: UIBarButtonItem?
    var optionItemBar: UIToolbar?
    var currentCharacters: Int = 140
    var currentCharactersView: UIBarButtonItem?

    var newTweetMedias: Array<String> = []
    var newTweetMediaViews: Array<UIImageView> = []
    var newTweetMediaCloseButton: Array<UIButton> = []
    var fTopCursor = false
    var fUploadProgress = false
    var suggestTable: UITableView?
    var suggestList: Array<String>?
    
    var minuteTableView: MinuteTableViewController?
    var selectedMinute: Int?
    
    var newTweetModel: NewTweetModel!
    
    //======================================
    //  instance methods
    //======================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    convenience init(aTweetBody: String!, aReplyToID: String?, aTopCursor: Bool?) {
        self.init()
        self.tweetBody = aTweetBody
        self.replyToID = aReplyToID
        if aTopCursor != nil {
            self.fTopCursor = aTopCursor!
        }
        self.title = "ツイート送信"
        self.newTweetModel = NewTweetModel()
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
        if (self.fTopCursor) {
            self.newTweetText.selectedTextRange = self.newTweetText.textRangeFromPosition(self.newTweetText.beginningOfDocument, toPosition: self.newTweetText.beginningOfDocument)
        }
        self.currentCharacters = 140 - self.newTweetText.text.characters.count
        
        self.minuteTableView = MinuteTableViewController()
        self.minuteTableView?.delegate = self
        
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
        self.currentCharacters = 140 - (textView.text.characters.count - range.length + text.characters.count)
        if (self.currentCharactersView != nil) {
            self.currentCharactersView?.title = String(self.currentCharacters)
        }
        
        self.newTweetModel.findScreenNameRange(textView.text, text: text, range: range, finishSelect: { () -> Void in
            self.removeSuggestTable()
        }) { (friends) -> Void in
            if let textRange = textView.selectedTextRange {
                let position = textView.caretRectForPosition(textRange.start)
                self.displaySuggestTable(friends, position: position)
            }
        }
        
        self.newTweetModel.findTagRange(textView.text, text: text, range: range, finishSelect: { () -> Void in
            // table削除
            self.removeSuggestTable()
        }) { (tags) -> Void in
            // tagsを元にテーブル更新
            if let textRange = textView.selectedTextRange {
                let position = textView.caretRectForPosition(textRange.start)
                self.displaySuggestTable(tags, position: position)
            }
        }
        
        return true
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
        let windowSize = UIScreen.mainScreen().bounds.size
        if let info = notification.userInfo as NSDictionary? {
            self.optionItemBar?.removeFromSuperview()
            if let keyboardSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue as CGRect? {
                self.optionItemBar = UIToolbar(frame: CGRectMake(0, keyboardSize.origin.y - self.optionItemBarHeight, windowSize.width, self.optionItemBarHeight))
            }
            self.optionItemBar?.backgroundColor = UIColor.lightGrayColor()
            // 配置するボタン
            let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            self.photostreamButton = UIBarButtonItem(image: UIImage(named: "Image"), style: UIBarButtonItemStyle.Plain, target: self, action: "openPhotostream")
            self.cameraButton = UIBarButtonItem(image: UIImage(named: "Camera-Line"), style: UIBarButtonItemStyle.Plain, target: self, action: "openCamera")
            self.minuteButton = UIBarButtonItem(title: "下書き", style: UIBarButtonItemStyle.Plain, target: self, action: "openMinute")
            self.currentCharactersView = UIBarButtonItem(title: String(self.currentCharacters), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            
            let itemArray = [spacer, self.photostreamButton!, spacer, self.cameraButton!, spacer, self.minuteButton!, spacer, self.currentCharactersView!]
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
        if (self.newTweetText.text.isEmpty) {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let minuteSheet = UIAlertController(title: "下書き保存しますか？", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let closeAction = UIAlertAction(title: "破棄する", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.newTweetText.text = ""
                self.navigationController?.popViewControllerAnimated(true)
            })
            let minuteAction = UIAlertAction(title: "下書き保存", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.minuteTableView?.addMinute(self.newTweetText.text as String, minuteReplyToID: self.replyToID)
                self.newTweetText.text = ""
                self.navigationController?.popViewControllerAnimated(true)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
            })
            minuteSheet.addAction(closeAction)
            minuteSheet.addAction(minuteAction)
            minuteSheet.addAction(cancelAction)
            self.presentViewController(minuteSheet, animated: true, completion: nil)
            
        }
        
    }
    
    func openPhotostream() {
        if (!self.fUploadProgress) {
            if (self.newTweetMedias.count < 4) {
                let ipc:UIImagePickerController = UIImagePickerController();
                ipc.delegate = self
                ipc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                ipc.allowsEditing = false
                self.presentViewController(ipc, animated:true, completion:nil)
            } else {
                let overContentsAlert = UIAlertController(title: "これ以上添付できません", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                })
                overContentsAlert.addAction(okAction)
                self.presentViewController(overContentsAlert, animated: true, completion: nil)
            }
        } else {
            let overContentsAlert = UIAlertController(title: "お待ちください", message: "画像のアップロードは一件ずつお願いします", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            overContentsAlert.addAction(okAction)
            self.presentViewController(overContentsAlert, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if (!self.fUploadProgress) {
            if (self.newTweetMedias.count < 4) {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
                {
                    //camera ok
                    let ipc:UIImagePickerController = UIImagePickerController()
                    ipc.delegate = self
                    ipc.sourceType = UIImagePickerControllerSourceType.Camera
                    ipc.allowsEditing = false
                    self.presentViewController(ipc, animated:true, completion:nil)
                }
            
            } else {
                let overContentsAlert = UIAlertController(title: "これ以上添付できません", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                })
                overContentsAlert.addAction(okAction)
                self.presentViewController(overContentsAlert, animated: true, completion: nil)
            }
        } else {
            let overContentsAlert = UIAlertController(title: "お待ちください", message: "画像のアップロードは一件ずつお願いします", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            overContentsAlert.addAction(okAction)
            self.presentViewController(overContentsAlert, animated: true, completion: nil)
        }
    }
    
    func openMinute() {
        if (self.minuteTableView != nil) {
            self.navigationController?.pushViewController(self.minuteTableView!, animated: true)
        }
        
    }
    
    func editImageViewController(editImageViewcontroller: EditImageViewController, rotationImage: UIImage) {
        var width = CGFloat(rotationImage.size.width)
        var height = CGFloat(rotationImage.size.height)
        
        if (rotationImage.size.width > rotationImage.size.height) {
            width = CGFloat(50.0)
            height = CGFloat(50.0 * rotationImage.size.height / rotationImage.size.width)
        } else {
            width = CGFloat(50.0 * rotationImage.size.width / rotationImage.size.height)
            height = CGFloat(50.0)
        }
        
        let uploadImageView = UIImageView(frame: CGRectMake(
            self.imageViewSpan + (self.imageViewSpan * 3 * CGFloat(self.newTweetMedias.count)),
            self.optionItemBar!.frame.origin.y - self.optionItemBarHeight * 2,
            width,
            height))
        uploadImageView.image = rotationImage
        self.view.addSubview(uploadImageView)
        self.newTweetMediaViews.append(uploadImageView)
        
        
        let progressView = DACircularProgressView(frame: CGRectMake(0, 0, width * 2.0 / 3.0, height * 2.0 / 3.0))
        progressView.center = CGPoint(x: width / 2.0, y: height / 2.0)
        progressView.roundedCorners = 0
        progressView.progressTintColor = self.progressColor
        progressView.trackTintColor = UIColor.grayColor()
        progressView.setProgress(0.0, animated: true)
        uploadImageView.addSubview(progressView)
        
        let closeImageView = UIButton(frame: CGRectMake(uploadImageView.frame.origin.x - 15.0, uploadImageView.frame.origin.y - 20, 20.0, 20.0))
        closeImageView.setImage(UIImage(named: "Close-Filled"), forState: UIControlState.Normal)
        closeImageView.addTarget(self, action: "removeImage:", forControlEvents: UIControlEvents.TouchUpInside)
        closeImageView.tag = self.newTweetMedias.count
        self.view.addSubview(closeImageView)
        self.newTweetMediaCloseButton.append(closeImageView)
        
        // upload処理
        // Whalebirdのapiにupload
        // ファイルパスだけ戻してもらってpostのparameterに付随させてtweet判定
        self.fUploadProgress = true
        WhalebirdAPIClient.sharedClient.postImage(rotationImage, progress: { (written) -> Void in
            progressView.setProgress(CGFloat(written), animated: true)
        }, complete: { (response) -> Void in
            print(response)
            self.newTweetMedias.append((response as NSDictionary).objectForKey("filename") as! String)
            progressView.removeFromSuperview()
            self.fUploadProgress = false
        }) { (error) -> Void in
            let removeIndex = self.newTweetMedias.count
            self.newTweetMediaViews[removeIndex].removeFromSuperview()
            self.newTweetMediaViews.removeAtIndex(removeIndex)
            self.newTweetMediaCloseButton[removeIndex].removeFromSuperview()
            self.newTweetMediaCloseButton.removeAtIndex(removeIndex)
            self.fUploadProgress = false
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if (info[UIImagePickerControllerOriginalImage] != nil) {
            if let image:UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                // カメラで撮影するだけでは保存はされていない
                if (picker.sourceType == UIImagePickerControllerSourceType.Camera) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
                // 編集画面を挟む
                let imageEditView = EditImageViewController(aPickerImage: image, aPicker: picker)
                picker.presentViewController(imageEditView, animated: true, completion: nil)
                imageEditView.delegate = self
            }
        }
    }

    func removeImage(id: AnyObject) {
        // upload中は移動を伴うキャンセルはロックする
        if let closeButton = id as? UIButton {
            let removeIndex = closeButton.tag
            if (self.fUploadProgress) {
                if (removeIndex == self.newTweetMedias.count) {
                    // 今まさにupload中のものだったとき
                    WhalebirdAPIClient.sharedClient.cancelRequest()
                }
            } else {
                closeButton.removeFromSuperview()
                self.newTweetMedias.removeAtIndex(removeIndex)
                // ここでuploadImageViewの削除と位置調節
                self.newTweetMediaViews[removeIndex].removeFromSuperview()
                self.newTweetMediaViews.removeAtIndex(removeIndex)
                self.newTweetMediaCloseButton[removeIndex].removeFromSuperview()
                self.newTweetMediaCloseButton.removeAtIndex(removeIndex)
                for (var index = 0; index < self.newTweetMediaViews.count; index++) {
                    self.newTweetMediaViews[index].frame.origin = CGPoint(x: self.imageViewSpan + (self.imageViewSpan * 3 * CGFloat(index)),
                        y: self.optionItemBar!.frame.origin.y - self.optionItemBarHeight * 2)
                    self.newTweetMediaCloseButton[index].frame.origin = CGPoint(x: self.newTweetMediaViews[index].frame.origin.x - 15.0, y: self.newTweetMediaViews[index].frame.origin.y - 20)
                    self.newTweetMediaCloseButton[index].tag = index
                }
            }
        }
    }

    //-----------------------------------------
    //  送信ボタンを押した時の処理
    //-----------------------------------------
    func onSendTapped() -> Bool {
        if (self.fUploadProgress) {
            let alertController = UIAlertController(title: "画像アップロード中です", message: "アップロード後にもう一度送信してください", preferredStyle: .Alert)
            let cOkAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alertController.addAction(cOkAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return false
        }
        if ((newTweetText.text as String).characters.count > 0 || self.newTweetMedias.count > 0) {
            postTweet(newTweetText.text)
            return true
        } else {
            let blankTweetAlert = UIAlertController(title: "ツイートできません", message: "本文を入力してください", preferredStyle: .Alert)
            let cOkAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            blankTweetAlert.addAction(cOkAction)
            self.presentViewController(blankTweetAlert, animated: true, completion: nil)
            return false
        }
    }
    
    
    //-----------------------------------------
    //  whalebirdにPOST
    //-----------------------------------------
    func postTweet(aTweetBody: NSString) {
        var params: Dictionary<String, AnyObject> = [:]
        var parameter: Dictionary<String, AnyObject> = [
            "status" : newTweetText.text
        ]
        if (self.replyToID != nil) {
            params["in_reply_to_status_id"] = self.replyToID!
        }
        if (self.newTweetMedias.count > 0) {
            params["medias"] = self.newTweetMedias
        }
        
        if (params.count != 0) {
            parameter["settings"] = params
        }
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/tweet.json", params: parameter) { (aOperation) -> Void in
            let q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                let notice = WBSuccessNoticeView.successNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "投稿しました")
                SVProgressHUD.dismiss()
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
                if self.selectedMinute != nil {
                    self.minuteTableView?.deleteMinute(self.selectedMinute!)
                }
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    func displaySuggestTable(suggest: Array<String>, position: CGRect) {
        self.suggestList = suggest
        // position計算
        let tableTop = self.navigationController!.navigationBar.frame.size.height +  UIApplication.sharedApplication().statusBarFrame.height + position.origin.y + position.height
        
        var tableHeight = self.maxSize.height
        if let optionBar = self.optionItemBar {
            tableHeight = optionBar.frame.origin.y - tableTop
        }
        if self.suggestTable == nil {
            self.suggestTable = UITableView(frame: CGRectMake(0, tableTop, self.maxSize.width, tableHeight))
            self.suggestTable!.delegate = self
            self.suggestTable!.dataSource = self
            self.view.addSubview(self.suggestTable!)
        } else {
            self.suggestTable!.frame = CGRectMake(0, tableTop, self.maxSize.width, tableHeight)
            self.suggestTable!.reloadData()
        }
    }
    
    func removeSuggestTable() {
        self.suggestTable?.removeFromSuperview()
        self.suggestTable = nil
    }
    
    func selectSuggestion(text: String) {
        let beginning = self.newTweetText.beginningOfDocument
        if self.newTweetModel.screenNameRange != nil {
            if let start = self.newTweetText.positionFromPosition(beginning, offset: self.newTweetModel.screenNameRange!.location) {
                var textRange: UITextRange!
                if let end = self.newTweetText.positionFromPosition(start, offset: self.newTweetModel.screenNameRange!.length + 1) {
                    textRange = self.newTweetText.textRangeFromPosition(start, toPosition: end)
                } else {
                    let end = self.newTweetText.positionFromPosition(start, offset: self.newTweetModel.screenNameRange!.length)
                    textRange = self.newTweetText.textRangeFromPosition(start, toPosition: end!)
                }
                self.newTweetText.replaceRange(textRange, withText: "@" + text + " ")
                self.newTweetModel.clearRange()
            }
        } else if self.newTweetModel.tagRange != nil {
            if let start = self.newTweetText.positionFromPosition(beginning, offset: self.newTweetModel.tagRange!.location) {
                var textRange: UITextRange!
                if let end = self.newTweetText.positionFromPosition(start, offset: self.newTweetModel.tagRange!.length + 1) {
                    textRange = self.newTweetText.textRangeFromPosition(start, toPosition: end)
                } else {
                    let end = self.newTweetText.positionFromPosition(start, offset: self.newTweetModel.tagRange!.length)
                    textRange = self.newTweetText.textRangeFromPosition(start, toPosition: end!)
                }
                self.newTweetText.replaceRange(textRange, withText: "#" + text + " ")
                self.newTweetModel.clearRange()
            }
        }
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.suggestList != nil {
            return self.suggestList!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        if self.suggestList != nil {
            cell.textLabel?.text = self.suggestList![indexPath.row] as String
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.suggestList != nil {
            self.selectSuggestion(self.suggestList![indexPath.row])
        }
        self.removeSuggestTable()
    }
    
    // 下書きが確定されたとき
    func rewriteTweetWithMinute(minute: NSDictionary, index: Int) {
        self.newTweetText.text = minute.objectForKey("text") as? String
        self.replyToID = minute.objectForKey("replyToID") as? String
        self.selectedMinute = index
    }
}
