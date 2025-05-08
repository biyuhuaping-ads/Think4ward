platform :ios, '15.0'

target 'Think4ward' do
  
  use_frameworks!
#  use_modular_headers!
  #  post_install do |pi|
#    pi.pods_project.targets.each do |t|
#      t.build_configurations.each do |config|
#        config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)']
#        config.build_settings['OTHER_SWIFT_FLAGS'] << '-enable-experimental-feature AccessLevelOnImport'
#        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
#        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#        config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
#        config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
#        config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
#        #          config.build_settings['ENABLE_BITCODE'] = "NO"
#        xcconfig_path = config.base_configuration_reference.real_path
#        xcconfig = File.read(xcconfig_path)
#        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
#        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
#        
#      end
#    end
#  end
  
  #  pod 'FirebaseAnalytics','10.14.0'
  #  #pod 'FirebaseCrashlytics'
  #  pod 'FirebaseAuth','10.14.0'
  #  pod 'FirebaseFirestore','10.14.0'
  
  pod 'AppLovinSDK', '13.1.0'  # 指定版本为 13.1.0
  pod 'Firebase/Analytics', :modular_headers => true
  pod 'Firebase/Auth', :modular_headers => true
  pod 'Firebase/Core', :modular_headers => true
  pod 'Firebase/Firestore', :modular_headers => true
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end

