platform :ios, '15.0'

target 'GBeacon' do

  pod 'AFNetworking'
  pod 'SDWebImage'
  pod 'Masonry'
  pod 'YYModel'
  pod 'SVProgressHUD', '2.0.3'
  pod 'Bugly'

end

post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      c.build_settings['CLANG_ENABLE_EXPLICIT_MODULES'] = 'NO'
    end
  end

  files = [
  'Pods/AFNetworking/AFNetworking/AFHTTPSessionManager.m',
  'Pods/AFNetworking/AFNetworking/AFNetworkReachabilityManager.m'
  ]
  
  files.each do |file|
    next unless File.exist?(file)
    
    text = File.read(file)
    text.gsub!('#import <netinet6/in6.h>', '#import <netinet/in.h>')
    File.write(file, text)
  end
end
