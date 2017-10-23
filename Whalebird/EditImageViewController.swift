//
//  EditImageViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/03/09.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

protocol EditImageViewControllerDelegate {
    func editImageViewController(_ editImageViewcontroller: EditImageViewController, rotationImage: UIImage)
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
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(aPickerImage: UIImage, aPicker: UIImagePickerController) {
        self.init()
        self.pickerImage = aPickerImage
        self.picker = aPicker
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        let cWindowSize = self.view.bounds
        
        self.imageView = UIImageView(image: self.pickerImage)
        self.resizeImageView()
        self.view.addSubview(self.imageView)
        
        self.toolBoxView = UIToolbar(frame: CGRect(x: 0, y: cWindowSize.size.height - self.toolBoxHeight, width: cWindowSize.size.width, height: self.toolBoxHeight))
        self.toolBoxView.barStyle = UIBarStyle.black
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Back", tableName: "EditImage", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditImageViewController.tappedCancel))
        let rotationButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(EditImageViewController.tappedRotation))
        let rotationToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        rotationToolBar.setItems([rotationButton], animated: true)
        rotationToolBar.barStyle = UIBarStyle.black
        rotationToolBar.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        let wrappedRotationButton = UIBarButtonItem(customView: rotationToolBar)
        let completeButton = UIBarButtonItem(title: NSLocalizedString("Done", tableName: "EditImage", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditImageViewController.tappedComplete))
        let itemArray = [spacer, cancelButton, spacer, wrappedRotationButton, spacer, completeButton, spacer]
        self.toolBoxView.setItems(itemArray, animated: true)
        
        self.view.addSubview(self.toolBoxView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tappedCancel() {
        // カメラのときは戻すだけだと操作不能になるのでpicker自体を消す
        self.dismiss(animated: true, completion: { () -> Void in
            if self.picker.sourceType == UIImagePickerControllerSourceType.camera {
                self.picker.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    //-----------------------------------------
    // ここではプレビューとしてimageViewを回転させる
    // image自体には触れない
    //-----------------------------------------
    @objc func tappedRotation() {
        self.rotationAngle += 90
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            
            let cWindowSize = self.view.bounds
            var scale = CGFloat(1.0)
            if (self.rotationAngle.truncatingRemainder(dividingBy: 180) != 0) {
                scale = cWindowSize.size.width / self.imageView.frame.size.height
            }
            
            // CGContextの回転方向と逆向き
            let rotationTransform = CGAffineTransform(rotationAngle: self.radian(-self.rotationAngle))
            self.imageView.transform = rotationTransform.scaledBy(x: scale, y: scale)
        }, completion: { (finished) -> Void in
            
        }) 
    }
    
    //----------------------------------------
    //  デリゲートの処理呼び出し
    //----------------------------------------
    @objc func tappedComplete() {
        let rotationImage = self.rotationAndResizeImage(self.pickerImage, angle: self.rotationAngle)
        self.dismiss(animated: true, completion: nil)
        self.picker.dismiss(animated: true, completion: nil)
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
            let scale = cWindowSize.size.width / self.imageView.frame.size.width
            self.imageView.frame.size = CGSize(width: cWindowSize.size.width, height: self.imageView.frame.size.height * scale)
        }
        if (self.imageView.frame.size.height > cWindowSize.size.height - self.toolBoxHeight) {
            let scale = (cWindowSize.size.height - self.toolBoxHeight) / self.imageView.frame.size.height
            self.imageView.frame.size = CGSize(width: self.imageView.frame.size.width * scale, height: cWindowSize.size.height - self.toolBoxHeight)
        }
        self.imageView.center = CGPoint(x: cWindowSize.size.width / 2.0, y: (cWindowSize.size.height - self.toolBoxHeight) / 2.0)
    }
    
    //-----------------------------------------------
    //  画像への回転・リサイズ処理は確定したときに行う
    //  アップロード用に画像はリサイズして軽量化
    //  resizeには軽さを求めるのでCoreGraphicsを使う
    //-----------------------------------------------
    func rotationAndResizeImage(_ srcImage: UIImage, angle: Float) -> UIImage {
        var targetWidth: CGFloat!
        var targetHeight: CGFloat!
        let normalizeAngle = angle.truncatingRemainder(dividingBy: 360)
        
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
        
        if (normalizeAngle.truncatingRemainder(dividingBy: 180) == 0) {
            targetWidth = sendWidth
            targetHeight = sendHeight
        } else {
            targetWidth = sendHeight
            targetHeight = sendWidth
        }
        
        
        let imageRef = srcImage.cgImage! as CGImage
        let bitmapInfo = imageRef.bitmapInfo as CGBitmapInfo
        let colorSpaceInfo = imageRef.colorSpace! as CGColorSpace
        
        
        var bitmap: CGContext!
        // bytesPerRowはwidthの4倍以上ないとメモリが足らない
        var longLength = targetWidth
        if longLength! < targetHeight {
            longLength = targetHeight
        }
        bitmap = CGContext(data: nil, width: Int(targetWidth), height: Int(targetHeight), bitsPerComponent: imageRef.bitsPerComponent, bytesPerRow: Int(longLength! * 4), space: colorSpaceInfo, bitmapInfo: bitmapInfo.rawValue)


        // 回転時の原点に合わせて予め移動させる
        switch(normalizeAngle) {
        case 0:
            break
        case 90:
            bitmap.translateBy(x: targetWidth, y: 0)
            break
        case 180:
            bitmap.translateBy(x: targetWidth, y: targetHeight)
            break
        case 270:
            bitmap.translateBy(x: 0, y: targetHeight)
            break
        default:
            break
        }
        bitmap.rotate(by: self.radian(normalizeAngle))
        
        if (srcImage.imageOrientation == UIImageOrientation.left) {
            bitmap.rotate(by: self.radian(90))
            bitmap.translateBy(x: 0, y: -sendWidth)
            bitmap.scaleBy(x: srcImage.size.height / srcImage.size.width, y: srcImage.size.width / srcImage.size.height)
        } else if (srcImage.imageOrientation == UIImageOrientation.right) {
            bitmap.rotate(by: self.radian(-90))
            bitmap.translateBy(x: -sendHeight, y: 0)
            bitmap.scaleBy(x: srcImage.size.height / srcImage.size.width, y: srcImage.size.width / srcImage.size.height)
        } else if (srcImage.imageOrientation == UIImageOrientation.up) {
        } else if (srcImage.imageOrientation == UIImageOrientation.down) {
            bitmap.translateBy(x: targetWidth, y: targetHeight)
            bitmap.rotate(by: self.radian(-180))
        }

        bitmap.draw(imageRef, in: CGRect(x: 0, y: 0, width: sendWidth, height: sendHeight))
        let ref = bitmap.makeImage()
        if let newImage = UIImage(cgImage: ref!) as UIImage? {
            return newImage
        } else {
            return srcImage
        }
    }
    
    func radian(_ degree: Float) -> CGFloat {
        return CGFloat(degree * 3.14159265358979323846 / 180.0)
    }
}
