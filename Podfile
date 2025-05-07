platform :ios, '15.0'
use_modular_headers!  # 添加这一行
target 'Think4ward' do

  pod 'AppLovinSDK'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'

end

# 添加 post_install 钩子，为所有 pod 目标设置编译标志
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 添加 Swift 编译标志
      config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)']
      config.build_settings['OTHER_SWIFT_FLAGS'] << '-enable-experimental-feature AccessLevelOnImport'
    end
  end
end

