source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "11.0"
swift_version = '4.0'
use_frameworks!

target "Whalebird" do
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
  pod 'RNCryptor'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'UrlShortener', git: "https://github.com/h3poteto/URL-Shortener.git"
  pod 'ReachabilitySwift'


  post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Whalebird/Pods-Whalebird-acknowledgements.plist', 'Whalebird/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  end

  target "WhalebirdTests" do
  end
end
