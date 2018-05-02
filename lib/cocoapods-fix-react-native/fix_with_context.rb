class CocoaPodsFixReactNative
  def post_fix_with_context(context)
    # Get the current version of React Native in your app
    react_spec = context.sandbox.specification('React')
    if react_spec.nil?
      Pod::UI.warn "No React dependency found"
      return
    end

    # 0.44.1 -> 0_44_1
    version = react.version.to_s
    file_to_parse = version.tr('.', '_') + '-post'
    path_to_fix = File.join(File.dirname(__FILE__), 'versions', file_to_parse + '.rb')

    if File.exist? path_to_fix
      Pod::UI.section "Patching React Native #{version}" do
        require(path_to_fix)
      end
    else
      Pod::UI.warn "CP-Fix-React-Native does not support #{version} yet, please send " +
                   'PRs to https://github.com/orta/cocoapods-fix-react-native'
    end
  end

  def pre_fix_with_context(context)
    # Get the current version of React Native in your app
    react_spec = context.sandbox.specification('React')
    if react_spec.nil?
      Pod::UI.warn "No React dependency found"
      return
    end

    # # 0.44.1 -> 0_44_1
    version = react_spec.version.to_s
    file_to_parse = version.tr('.', '_') + '-pre'
    path_to_fix = File.join(File.dirname(__FILE__), 'versions', file_to_parse + '.rb')

    if File.exist? path_to_fix
      Pod::UI.section "Patching React Native #{version}" do
        require(path_to_fix)
      end
    else
      # There will probably always be a neeed for the post, but a pre can be ignored
      Pod::UI.warn "CP-Fix-React-Native does not support #{version} yet, please send " +
                   'PRs to https://github.com/orta/cocoapods-fix-react-native'
    end
  end
end
