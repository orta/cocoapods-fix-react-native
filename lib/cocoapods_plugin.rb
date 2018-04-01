require 'cocoapods-fix-react-native/version_resolver'

Pod::HooksManager.register('cocoapods-fix-react-native', :post_install) do |context, options|
  fixer = CocoaPodsFixReactNative.new
  fixer.fix_with_context(context)
end
