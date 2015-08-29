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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(animatedImageURL: NSURL, windowSize: CGRect) {
        self.init(frame: windowSize)
        var playerItem = AVPlayerItem(URL: animatedImageURL)
        self.videoPlayer = AVPlayer(playerItem: playerItem)
        self.setPlayer(videoPlayer)
        self.setVideoFillMode(AVLayerVideoGravityResizeAspect)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        self.videoPlayer.play()
    }
    
    override class func layerClass() -> AnyClass{
        return AVPlayerLayer.self
    }
    func player() -> AVPlayer {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        return layer.player!
    }
    
    func setPlayer(player: AVPlayer) {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        layer.player = player
    }
    
    func setVideoFillMode(fillMode: NSString) {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        layer.videoGravity = fillMode as String
    }
    
    func videoFillMode() -> NSString {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        return layer.videoGravity
    }
    
    func playerItemDidReachEnd(sender: AnyObject) {
        self.videoPlayer.seekToTime(kCMTimeZero)
        self.videoPlayer.play()
    }

}
