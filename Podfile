platform :ios, '15.0'

target 'Think4ward' do
  use_frameworks!
  pod 'AppLovinSDK', '13.1.0'  # 指定版本为 13.1.0
  pod 'Firebase/Analytics'#, :modular_headers => true
  pod 'Firebase/Auth'#, :modular_headers => true
  pod 'Firebase/Core'#, :modular_headers => true
  pod 'Firebase/Firestore'#, :modular_headers => true
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

