source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "8.1"
pod 'TSMessages'
pod 'NoticeView'
pod 'OHAttributedLabel'
pod 'SVPullToRefresh', :head
pod 'AFNetworking','~> 2.0'
pod 'SVProgressHUD'
pod 'TTTAttributedLabel'
pod 'DACircularProgress'
pod 'ODRefreshControl'
pod 'SwipeView'
pod 'SDWebImage'
pod 'RNCryptor'
pod 'Fabric','~>1.0'
pod 'Fabric/Crashlytics'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Whalebird/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
