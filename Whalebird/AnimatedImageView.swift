//
//  AnimatedImageView.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/08/29.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit
import AVFoundation

class AnimatedImageView: UIView {
    var videoPlayer: AVPlayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(animatedImageURL: URL, windowSize: CGRect) {
        self.init(frame: windowSize)
        let playerItem = AVPlayerItem(url: animatedImageURL)
        self.videoPlayer = AVPlayer(playerItem: playerItem)
        self.setPlayer(videoPlayer)
        self.setVideoFillMode(AVLayerVideoGravity.resizeAspect as NSString)
        NotificationCenter.default.addObserver(self, selector: #selector(AnimatedImageView.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        self.videoPlayer.play()
    }
    
    override class var layerClass : AnyClass{
        return AVPlayerLayer.self
    }
    func player() -> AVPlayer {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        return layer.player!
    }
    
    func setPlayer(_ player: AVPlayer) {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        layer.player = player
    }
    
    func setVideoFillMode(_ fillMode: NSString) {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        layer.videoGravity = AVLayerVideoGravity(rawValue: fillMode as String as String)
    }
    
    func videoFillMode() -> NSString {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        return layer.videoGravity as NSString
    }
    
    @objc func playerItemDidReachEnd(_ sender: AnyObject) {
        self.videoPlayer.seek(to: kCMTimeZero)
        self.videoPlayer.play()
    }

}
