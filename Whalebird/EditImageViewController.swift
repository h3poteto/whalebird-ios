//
//  EditImageViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/03/09.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

protocol EditImageViewControllerDelegate {
    func editImageViewController(editImageViewcontroller: EditImageViewController, rotationImage: UIImage)
}

class EditImageViewController: UIViewController {

    //=============================================
    //  instance variables
    //=============================================
    let toolBoxHeight = CGFloat(50)
    
    var toolBoxView: UIToolbar!
    var pickerImage: UIImage!
    var picker: UIImagePickerController!
    var imageView: UIImageView!
    var rotationAngle = Float(0)
    
    var delegate: EditImageViewControllerDelegate!
    
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(aPickerImage: UIImage, aPicker: UIImagePickerController) {
        self.init()
        self.pickerImage = aPickerImage
        self.picker = aPicker
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        let cWindowSize = self.view.bounds
        
        self.imageView = UIImageView(image: self.pickerImage)
        self.resizeImageView()
        self.view.addSubview(self.imageView)
        
        self.toolBoxView = UIToolbar(frame: CGRectMake(0, cWindowSize.size.height - self.toolBoxHeight, cWindowSize.size.width, self.toolBoxHeight))
        self.toolBoxView.barStyle = UIBarStyle.Black
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "戻る", style: UIBarButtonItemStyle.Plain, target: self, action: "tappedCancel")
        let rotationButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "tappedRotation")
        var rotationToolBar = UIToolbar(frame: CGRectMake(0, 0, 50, 50))
        rotationToolBar.setItems([rotationButton], animated: true)
        rotationToolBar.barStyle = UIBarStyle.Black
        rotationToolBar.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        let wrappedRotationButton = UIBarButtonItem(customView: rotationToolBar)
        let completeButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: "tappedComplete")
        let itemArray = [spacer, cancelButton, spacer, wrappedRotationButton, spacer, completeButton, spacer]
        self.toolBoxView.setItems(itemArray, animated: true)
        
        self.view.addSubview(self.toolBoxView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedCancel() {
        // カメラのときは戻すだけだと操作不能になるのでpicker自体を消す
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if self.picker.sourceType == UIImagePickerControllerSourceType.Camera {
                self.picker.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    //-----------------------------------------
    // ここではプレビューとしてimageViewを回転させる
    // image自体には触れない
    //-----------------------------------------
    func tappedRotation() {
        self.rotationAngle += 90
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            
            let cWindowSize = self.view.bounds
            var scale = CGFloat(1.0)
            if (self.rotationAngle % 180 != 0) {
                scale = cWindowSize.size.width / self.imageView.frame.size.height
            }
            
            // CGContextの回転方向と逆向き
            let rotationTransform = CGAffineTransformMakeRotation(self.radian(-self.rotationAngle))
            self.imageView.transform = CGAffineTransformScale(rotationTransform, scale, scale)
        }) { (finished) -> Void in
            
        }
    }
    
    //----------------------------------------
    //  デリゲートの処理呼び出し
    //----------------------------------------
    func tappedComplete() {
        var rotationImage = self.rotationAndResizeImage(self.pickerImage, angle: self.rotationAngle)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.picker.dismissViewControllerAnimated(true, completion: nil)
        self.delegate.editImageViewController(self, rotationImage: rotationImage)
        /* for debugging
        self.imageView.removeFromSuperview()
        self.imageView = UIImageView(image: rotationImage)
        self.resizeImageView()
        self.view.addSubview(self.imageView)*/
    }
    
    //-----------------------------------
    // imageView自体のサイズ変更
    //-----------------------------------
    func resizeImageView() {
        let cWindowSize = self.view.bounds
        if (self.imageView.frame.size.width > cWindowSize.size.width) {
            var scale = cWindowSize.size.width / self.imageView.frame.size.width
            self.imageView.frame.size = CGSizeMake(cWindowSize.size.width, self.imageView.frame.size.height * scale)
        }
        if (self.imageView.frame.size.height > cWindowSize.size.height - self.toolBoxHeight) {
            var scale = (cWindowSize.size.height - self.toolBoxHeight) / self.imageView.frame.size.height
            self.imageView.frame.size = CGSizeMake(self.imageView.frame.size.width * scale, cWindowSize.size.height - self.toolBoxHeight)
        }
        self.imageView.center = CGPoint(x: cWindowSize.size.width / 2.0, y: (cWindowSize.size.height - self.toolBoxHeight) / 2.0)
    }
    
    //-----------------------------------------------
    //  画像への回転・リサイズ処理は確定したときに行う
    //  アップロード用に画像はリサイズして軽量化
    //  resizeには軽さを求めるのでCoreGraphicsを使う
    //-----------------------------------------------
    func rotationAndResizeImage(srcImage: UIImage, angle: Float) -> UIImage {
        var targetWidth: CGFloat!
        var targetHeight: CGFloat!
        let normalizeAngle = angle % 360
        
        // アス比を固定したままリサイズ
        var sendWidth = CGFloat(srcImage.size.width)
        var sendHeight = CGFloat(srcImage.size.height)
        if (srcImage.size.width > 800 || srcImage.size.height > 800) {
            if (srcImage.size.width > srcImage.size.height) {
                sendWidth = CGFloat(800.0)
                sendHeight = CGFloat(800.0 * srcImage.size.height / srcImage.size.width)
            } else {
                sendWidth = CGFloat(800.0 * srcImage.size.width / srcImage.size.height)
                sendHeight = CGFloat(800.0)
            }
        }
        
        if (normalizeAngle % 180 == 0) {
            targetWidth = sendWidth
            targetHeight = sendHeight
        } else {
            targetWidth = sendHeight
            targetHeight = sendWidth
        }
        
        
        let imageRef = srcImage.CGImage as CGImageRef
        let bitmapInfo = CGImageGetBitmapInfo(imageRef) as CGBitmapInfo
        let colorSpaceInfo = CGImageGetColorSpace(imageRef) as CGColorSpaceRef
        
        
        var bitmap: CGContextRef!
        // bytesPerRowはwidthの4倍以上ないとメモリが足らない
        var longLength = targetWidth
        if (longLength < targetHeight) {
            longLength = targetHeight
        }
        bitmap = CGBitmapContextCreate(nil, Int(targetWidth), Int(targetHeight), CGImageGetBitsPerComponent(imageRef), Int(longLength * 4), colorSpaceInfo, bitmapInfo)


        // 回転時の原点に合わせて予め移動させる
        switch(normalizeAngle) {
        case 0:
            break
        case 90:
            CGContextTranslateCTM(bitmap, targetWidth, 0)
            break
        case 180:
            CGContextTranslateCTM(bitmap, targetWidth, targetHeight)
            break
        case 270:
            CGContextTranslateCTM(bitmap, 0, targetHeight)
            break
        default:
            break
        }
        CGContextRotateCTM(bitmap, self.radian(normalizeAngle))
        
        if (srcImage.imageOrientation == UIImageOrientation.Left) {
            CGContextRotateCTM(bitmap, self.radian(90))
            CGContextTranslateCTM(bitmap, 0, -sendWidth)
            CGContextScaleCTM(bitmap, srcImage.size.height / srcImage.size.width, srcImage.size.width / srcImage.size.height)
        } else if (srcImage.imageOrientation == UIImageOrientation.Right) {
            CGContextRotateCTM(bitmap, self.radian(-90))
            CGContextTranslateCTM(bitmap, -sendHeight, 0)
            CGContextScaleCTM(bitmap, srcImage.size.height / srcImage.size.width, srcImage.size.width / srcImage.size.height)
        } else if (srcImage.imageOrientation == UIImageOrientation.Up) {
        } else if (srcImage.imageOrientation == UIImageOrientation.Down) {
            CGContextTranslateCTM(bitmap, targetWidth, targetHeight)
            CGContextRotateCTM(bitmap, self.radian(-180))
        }

        CGContextDrawImage(bitmap, CGRectMake(0, 0, sendWidth, sendHeight), imageRef)
        var ref = CGBitmapContextCreateImage(bitmap)
        if let newImage = UIImage(CGImage: ref) as UIImage? {
            return newImage
        } else {
            return srcImage
        }
    }
    
    func radian(degree: Float) -> CGFloat {
        return CGFloat(degree * 3.14159265358979323846 / 180.0)
    }
}
