require 'cocoapods-fix-react-native/version_resolver'

Pod::HooksManager.register('cocoapods-fix-react-native', :post_install) do |context|
  
  # Check that the min version of iOS has been set right for CocoaPods
  # This happens when a pod has a lower than iOS 6 deployment target.
  all_pods_targets = context.pods_project.targets
  all_pods_targets.each do |t|
    deployment_target = t.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
    if deployment_target == '4.3'
      raise 'You have a Pod who has a deployment target of 4.3.' + 
            "\nIn order for React Native to compile you need to give the Podspec for #{t.name} a version like `s.platform = :ios, '9.0'`.\n"
    end
  end

  fixer = CocoaPodsFixReactNative.new
  fixer.fix_with_context(context)
end
