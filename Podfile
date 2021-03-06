plugin 'cocoapods-acknowledgements'

# Uncomment this line to define a global platform for your project
platform :ios, '13.0'

def pod_settings
  # Uncomment this line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
end

def onesignal
  pod 'OneSignal', '>= 2.6.2', '< 3.0'
end

def swift_lint
  pod 'SwiftLint'
end

def opass_pods
  # Pods for OPass
  pod 'UICKeyChainStore', '~> 2.1'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'ICViewPager', :git => 'https://github.com/FrankWu100/ICViewPager'
  pod 'STPopup', '~> 1.7'
  pod 'ColorArt', '0.1.1'
  pod 'iCarousel', '~> 1.8'
  pod 'BLKFlexibleHeightBar', '~> 1.0'
  pod 'Nuke', '~> 9.1'
  pod 'Shimmer', '~> 1.0'
  pod 'CPDAcknowledgements', :git => 'https://github.com/FrankWu100/CPDAcknowledgements'
  pod 'NJKWebViewProgress', '~> 0.2'
  pod 'iVersion', '~> 1.11'
  pod 'AFNetworking', '~> 4.0'
  pod 'UITableView+FDTemplateLayoutCell', :git => 'https://github.com/Haraguroicha/UITableView-FDTemplateLayoutCell', :tag => '1.6.1'
  pod 'UIView+FDCollapsibleConstraints', '~> 1.1'
  pod 'EFQRCode', '~> 5.1.6'
  pod 'MBProgressHUD', '~> 1.1'
  pod 'FSPagerView'
  pod 'Collection'
  pod 'thenPromise'
  pod 'Down'
  pod 'FontAwesome.swift'
  pod 'SwiftDate'
  pod 'Appirater'
  pod 'SwiftyJSON'
  pod 'FoldingCell'
  pod 'DLLocalNotifications'
  pod 'TagListView'
  pod 'TimelineTableViewCell'
  pod 'Device.swift'
  pod 'CryptoSwift', '~> 1.0'
end

target 'OPass' do
  pod_settings
  onesignal
  opass_pods
  swift_lint
end

target 'OPass Notification Service' do
  pod_settings
  onesignal
  swift_lint
end

DEFAULT_SWIFT_VERSION = '5.0'
POD_SWIFT_VERSION_MAP = {

}

post_install do |installer|
  installer.pods_project.targets.each do |target|
    swift_version = POD_SWIFT_VERSION_MAP[target.name] || DEFAULT_SWIFT_VERSION
    puts "Setting #{target.name} Swift version to #{swift_version} and iOS 13.0 SDK"
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = swift_version
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
