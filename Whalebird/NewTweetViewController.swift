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
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "ツイート送信"
        self.newTweetModel = NewTweetModel()
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
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cWindowSize = UIScreen.main.bounds

        self.maxSize = cWindowSize.size
        
        self.cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewTweetViewController.onCancelTapped))
        self.navigationItem.leftBarButtonItem = self.cancelButton
        
        self.sendButton = UIBarButtonItem(title: "送信", style: UIBarButtonItemStyle.done, target: self, action: #selector(NewTweetViewController.onSendTapped))
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.newTweetText = UITextView(frame: CGRect(x: 0, y: 0, width: self.maxSize.width, height: self.maxSize.height / 2.0))
        self.newTweetText.isEditable = true
        self.newTweetText.delegate = self
        self.newTweetText.font = UIFont(name: TimelineViewCell.NormalFont, size: 18)
        self.view.addSubview(self.newTweetText)
        
        self.newTweetText.keyboardAppearance = UIKeyboardAppearance.light
        self.newTweetText.text = self.tweetBody
        self.newTweetText.becomeFirstResponder()
        if (self.fTopCursor) {
            self.newTweetText.selectedTextRange = self.newTweetText.textRange(from: self.newTweetText.beginningOfDocument, to: self.newTweetText.beginningOfDocument)
        }
        self.currentCharacters = 140 - self.newTweetText.text.characters.count
        
        self.minuteTableView = MinuteTableViewController()
        self.minuteTableView?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewTweetViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewTweetViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.currentCharacters = 140 - (textView.text.characters.count - range.length + text.characters.count)
        if (self.currentCharactersView != nil) {
            self.currentCharactersView?.title = String(self.currentCharacters)
        }
        
        self.newTweetModel.findScreenNameRange(textView.text, text: text, range: range, finishSelect: { () -> Void in
            self.removeSuggestTable()
        }) { (friends) -> Void in
            if let textRange = textView.selectedTextRange {
                let position = textView.caretRect(for: textRange.start)
                self.displaySuggestTable(friends, position: position)
            }
        }
        
        self.newTweetModel.findTagRange(textView.text, text: text, range: range, finishSelect: { () -> Void in
            // table削除
            self.removeSuggestTable()
        }) { (tags) -> Void in
            // tagsを元にテーブル更新
            if let textRange = textView.selectedTextRange {
                let position = textView.caretRect(for: textRange.start)
                self.displaySuggestTable(tags, position: position)
            }
        }
        
        return true
    }
    
    func keyboardDidShow(_ notification: Notification) {
        
        let windowSize = UIScreen.main.bounds.size
        if let info = (notification as NSNotification).userInfo as NSDictionary? {
            self.optionItemBar?.removeFromSuperview()
            if let keyboardSize = (info.object(forKey: UIKeyboardFrameEndUserInfoKey) as AnyObject).cgRectValue as CGRect? {
                self.optionItemBar = UIToolbar(frame: CGRect(x: 0, y: keyboardSize.origin.y - self.optionItemBarHeight, width: windowSize.width, height: self.optionItemBarHeight))
            }
            self.optionItemBar?.backgroundColor = UIColor.lightGray
            // 配置するボタン
            let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            self.photostreamButton = UIBarButtonItem(image: UIImage(named: "Image"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewTweetViewController.openPhotostream))
            self.cameraButton = UIBarButtonItem(image: UIImage(named: "Camera-Line"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewTweetViewController.openCamera))
            self.minuteButton = UIBarButtonItem(title: "下書き", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewTweetViewController.openMinute))
            self.currentCharactersView = UIBarButtonItem(title: String(self.currentCharacters), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            
            let itemArray = [spacer, self.photostreamButton!, spacer, self.cameraButton!, spacer, self.minuteButton!, spacer, self.currentCharactersView!]
            self.optionItemBar?.setItems(itemArray, animated: true)
            
            self.view.addSubview(self.optionItemBar!)
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if (self.optionItemBar != nil) {
            self.optionItemBar?.removeFromSuperview()
        }
    }
    
    func onCancelTapped() {
        if (self.newTweetText.text.isEmpty) {
            self.navigationController?.popViewController(animated: true)
        } else {
            let minuteSheet = UIAlertController(title: "下書き保存しますか？", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let closeAction = UIAlertAction(title: "破棄する", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.newTweetText.text = ""
                self.navigationController?.popViewController(animated: true)
            })
            let minuteAction = UIAlertAction(title: "下書き保存", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.minuteTableView?.addMinute(self.newTweetText.text as String, minuteReplyToID: self.replyToID)
                self.newTweetText.text = ""
                self.navigationController?.popViewController(animated: true)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                
            })
            minuteSheet.addAction(closeAction)
            minuteSheet.addAction(minuteAction)
            minuteSheet.addAction(cancelAction)
            self.present(minuteSheet, animated: true, completion: nil)
            
        }
        
    }
    
    func openPhotostream() {
        if (!self.fUploadProgress) {
            if (self.newTweetMedias.count < 4) {
                let ipc:UIImagePickerController = UIImagePickerController();
                ipc.delegate = self
                ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
                ipc.allowsEditing = false
                self.present(ipc, animated:true, completion:nil)
            } else {
                let overContentsAlert = UIAlertController(title: "これ以上添付できません", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                overContentsAlert.addAction(okAction)
                self.present(overContentsAlert, animated: true, completion: nil)
            }
        } else {
            let overContentsAlert = UIAlertController(title: "お待ちください", message: "画像のアップロードは一件ずつお願いします", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            overContentsAlert.addAction(okAction)
            self.present(overContentsAlert, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if (!self.fUploadProgress) {
            if (self.newTweetMedias.count < 4) {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
                {
                    //camera ok
                    let ipc:UIImagePickerController = UIImagePickerController()
                    ipc.delegate = self
                    ipc.sourceType = UIImagePickerControllerSourceType.camera
                    ipc.allowsEditing = false
                    self.present(ipc, animated:true, completion:nil)
                }
            
            } else {
                let overContentsAlert = UIAlertController(title: "これ以上添付できません", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                })
                overContentsAlert.addAction(okAction)
                self.present(overContentsAlert, animated: true, completion: nil)
            }
        } else {
            let overContentsAlert = UIAlertController(title: "お待ちください", message: "画像のアップロードは一件ずつお願いします", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            overContentsAlert.addAction(okAction)
            self.present(overContentsAlert, animated: true, completion: nil)
        }
    }
    
    func openMinute() {
        if (self.minuteTableView != nil) {
            self.navigationController?.pushViewController(self.minuteTableView!, animated: true)
        }
        
    }
    
    func editImageViewController(_ editImageViewcontroller: EditImageViewController, rotationImage: UIImage) {
        var width = CGFloat(rotationImage.size.width)
        var height = CGFloat(rotationImage.size.height)
        
        if (rotationImage.size.width > rotationImage.size.height) {
            width = CGFloat(50.0)
            height = CGFloat(50.0 * rotationImage.size.height / rotationImage.size.width)
        } else {
            width = CGFloat(50.0 * rotationImage.size.width / rotationImage.size.height)
            height = CGFloat(50.0)
        }
        
        let uploadImageView = UIImageView(frame: CGRect(
            x: self.imageViewSpan + (self.imageViewSpan * 3 * CGFloat(self.newTweetMedias.count)),
            y: self.optionItemBar!.frame.origin.y - self.optionItemBarHeight * 2,
            width: width,
            height: height))
        uploadImageView.image = rotationImage
        self.view.addSubview(uploadImageView)
        self.newTweetMediaViews.append(uploadImageView)
        
        
        let progressView = DACircularProgressView(frame: CGRect(x: 0, y: 0, width: width * 2.0 / 3.0, height: height * 2.0 / 3.0))
        progressView.center = CGPoint(x: width / 2.0, y: height / 2.0)
        progressView.roundedCorners = 0
        progressView.progressTintColor = self.progressColor
        progressView.trackTintColor = UIColor.gray
        progressView.setProgress(0.0, animated: true)
        uploadImageView.addSubview(progressView)
        
        let closeImageView = UIButton(frame: CGRect(x: uploadImageView.frame.origin.x - 15.0, y: uploadImageView.frame.origin.y - 20, width: 20.0, height: 20.0))
        closeImageView.setImage(UIImage(named: "Close-Filled"), for: UIControlState())
        closeImageView.addTarget(self, action: #selector(NewTweetViewController.removeImage(_:)), for: UIControlEvents.touchUpInside)
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
            self.newTweetMedias.append((response as NSDictionary).object(forKey: "filename") as! String)
            progressView.removeFromSuperview()
            self.fUploadProgress = false
        }) { (error) -> Void in
            let removeIndex = self.newTweetMedias.count
            self.newTweetMediaViews[removeIndex].removeFromSuperview()
            self.newTweetMediaViews.remove(at: removeIndex)
            self.newTweetMediaCloseButton[removeIndex].removeFromSuperview()
            self.newTweetMediaCloseButton.remove(at: removeIndex)
            self.fUploadProgress = false
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if (info[UIImagePickerControllerOriginalImage] != nil) {
            if let image:UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                // カメラで撮影するだけでは保存はされていない
                if (picker.sourceType == UIImagePickerControllerSourceType.camera) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
                // 編集画面を挟む
                let imageEditView = EditImageViewController(aPickerImage: image, aPicker: picker)
                picker.present(imageEditView, animated: true, completion: nil)
                imageEditView.delegate = self
            }
        }
    }

    func removeImage(_ id: AnyObject) {
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
                self.newTweetMedias.remove(at: removeIndex)
                // ここでuploadImageViewの削除と位置調節
                self.newTweetMediaViews[removeIndex].removeFromSuperview()
                self.newTweetMediaViews.remove(at: removeIndex)
                self.newTweetMediaCloseButton[removeIndex].removeFromSuperview()
                self.newTweetMediaCloseButton.remove(at: removeIndex)
                for index in 0 ..< self.newTweetMediaViews.count {
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
            let alertController = UIAlertController(title: "画像アップロード中です", message: "アップロード後にもう一度送信してください", preferredStyle: .alert)
            let cOkAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            alertController.addAction(cOkAction)
            self.present(alertController, animated: true, completion: nil)
            
            return false
        }
        if ((newTweetText.text as String).characters.count > 0 || self.newTweetMedias.count > 0) {
            postTweet(newTweetText.text as NSString)
            return true
        } else {
            let blankTweetAlert = UIAlertController(title: "ツイートできません", message: "本文を入力してください", preferredStyle: .alert)
            let cOkAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            })
            blankTweetAlert.addAction(cOkAction)
            self.present(blankTweetAlert, animated: true, completion: nil)
            return false
        }
    }
    
    
    //-----------------------------------------
    //  whalebirdにPOST
    //-----------------------------------------
    func postTweet(_ aTweetBody: NSString) {
        var params: Dictionary<String, AnyObject> = [:]
        var parameter: Dictionary<String, AnyObject> = [
            "status" : newTweetText.text as AnyObject
        ]
        if (self.replyToID != nil) {
            params["in_reply_to_status_id"] = self.replyToID! as AnyObject?
        }
        if (self.newTweetMedias.count > 0) {
            params["medias"] = self.newTweetMedias as AnyObject?
        }
        
        if (params.count != 0) {
            parameter["settings"] = params as AnyObject?
        }
        SVProgressHUD.show(withStatus: "キャンセル", maskType: SVProgressHUDMaskType.clear)
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/tweet.json", params: parameter) { (aOperation) -> Void in
            let q_main = DispatchQueue.main
            q_main.async(execute: {()->Void in
                let notice = WBSuccessNoticeView.successNotice(in: UIApplication.shared.delegate?.window!, title: "投稿しました")
                SVProgressHUD.dismiss()
                notice.alpha = 0.8
                notice.originY = (UIApplication.shared.delegate as! AppDelegate).alertPosition
                notice.show()
                if self.selectedMinute != nil {
                    self.minuteTableView?.deleteMinute(self.selectedMinute!)
                }
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func displaySuggestTable(_ suggest: Array<String>, position: CGRect) {
        self.suggestList = suggest
        // position計算
        let tableTop = self.navigationController!.navigationBar.frame.size.height +  UIApplication.shared.statusBarFrame.height + position.origin.y + position.height
        
        var tableHeight = self.maxSize.height
        if let optionBar = self.optionItemBar {
            tableHeight = optionBar.frame.origin.y - tableTop
        }
        if self.suggestTable == nil {
            self.suggestTable = UITableView(frame: CGRect(x: 0, y: tableTop, width: self.maxSize.width, height: tableHeight))
            self.suggestTable!.delegate = self
            self.suggestTable!.dataSource = self
            self.view.addSubview(self.suggestTable!)
        } else {
            self.suggestTable!.frame = CGRect(x: 0, y: tableTop, width: self.maxSize.width, height: tableHeight)
            self.suggestTable!.reloadData()
        }
    }
    
    func removeSuggestTable() {
        self.suggestTable?.removeFromSuperview()
        self.suggestTable = nil
    }
    
    func selectSuggestion(_ text: String) {
        let beginning = self.newTweetText.beginningOfDocument
        if self.newTweetModel.screenNameRange != nil {
            if let start = self.newTweetText.position(from: beginning, offset: self.newTweetModel.screenNameRange!.location) {
                var textRange: UITextRange!
                if let end = self.newTweetText.position(from: start, offset: self.newTweetModel.screenNameRange!.length + 1) {
                    textRange = self.newTweetText.textRange(from: start, to: end)
                } else {
                    let end = self.newTweetText.position(from: start, offset: self.newTweetModel.screenNameRange!.length)
                    textRange = self.newTweetText.textRange(from: start, to: end!)
                }
                self.newTweetText.replace(textRange, withText: "@" + text + " ")
                self.newTweetModel.clearRange()
            }
        } else if self.newTweetModel.tagRange != nil {
            if let start = self.newTweetText.position(from: beginning, offset: self.newTweetModel.tagRange!.location) {
                var textRange: UITextRange!
                if let end = self.newTweetText.position(from: start, offset: self.newTweetModel.tagRange!.length + 1) {
                    textRange = self.newTweetText.textRange(from: start, to: end)
                } else {
                    let end = self.newTweetText.position(from: start, offset: self.newTweetModel.tagRange!.length)
                    textRange = self.newTweetText.textRange(from: start, to: end!)
                }
                self.newTweetText.replace(textRange, withText: "#" + text + " ")
                self.newTweetModel.clearRange()
            }
        }
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.suggestList != nil {
            return self.suggestList!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        if self.suggestList != nil {
            cell.textLabel?.text = self.suggestList![(indexPath as NSIndexPath).row] as String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.suggestList != nil {
            self.selectSuggestion(self.suggestList![(indexPath as NSIndexPath).row])
        }
        self.removeSuggestTable()
    }
    
    // 下書きが確定されたとき
    func rewriteTweetWithMinute(_ minute: NSDictionary, index: Int) {
        self.newTweetText.text = minute.object(forKey: "text") as? String
        self.replyToID = minute.object(forKey: "replyToID") as? String
        self.selectedMinute = index
    }
}
