source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "8.1"

pod 'TSMessages'
pod 'NoticeView'
pod 'OHAttributedLabel'
pod 'SVPullToRefresh', git: "https://github.com/samvermette/SVPullToRefresh.git"
pod 'AFNetworking','~> 2.0'
pod 'SVProgressHUD'
pod 'TTTAttributedLabel'
pod 'DACircularProgress'
pod 'ODRefreshControl'
pod 'SwipeView'
pod 'SDWebImage'
pod 'RNCryptor', git: "https://github.com/h3poteto/RNCryptor.git", branch: "master"
pod 'Fabric'
pod 'Crashlytics'
pod 'UrlShortener', git: "https://github.com/h3poteto/URL-Shortener.git"
pod 'IJReachability', git: 'https://github.com/thejourneydude/IJReachability.git', branch: 'swift2-with-autodetect'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Whalebird/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

use_frameworks!
