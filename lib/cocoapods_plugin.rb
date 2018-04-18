require 'cocoapods-fix-react-native/fix_with_context'
require 'cocoapods-fix-react-native/issues/react_dependency_version'

Pod::HooksManager.register('cocoapods-fix-react-native', :pre_install) do |context|
  # The pre-fix resolver, usually for modifying Podspecs
  fixer = CocoaPodsFixReactNative.new
  fixer.pre_fix_with_context(context)
end


Pod::HooksManager.register('cocoapods-fix-react-native', :post_install) do |context|
  # Check that the min version of iOS has been set right for CocoaPods
  # This happens when a pod has a lower than iOS 6 deployment target.
  dep_version = ReactDependencyVersion.new
  dep_version.fix_with_context(context)

  # The post-fix resolver, for editing the RN source code after it's been installed
  fixer = CocoaPodsFixReactNative.new
  fixer.post_fix_with_context(context)
end
