platform :ios, '15.0'
use_modular_headers!  # 添加这一行，替换 use_frameworks!

target 'Think4ward' do
  pod 'AppLovinSDK', '13.1.0'  # 指定版本为 13.1.0
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)']
      config.build_settings['OTHER_SWIFT_FLAGS'] << '-enable-experimental-feature AccessLevelOnImport'
      # 确保项目支持 iOS 15.0
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end



