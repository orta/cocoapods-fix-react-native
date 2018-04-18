class CocoaPodsFixReactNative
  def post_fix_with_context(context)
    # Get the current version of React Native in your app
    react = nil
    context.umbrella_targets.each do |target|
      react_spec = target.specs.find { |s| s.name == 'React' || s.name.start_with?('React/') }
      react = react_spec if react_spec
    end

    # 0.44.1 -> 0_44_1
    version = react.version.to_s
    file_to_parse = version.tr('.', '_') + "-" + version
    path_to_fix = File.join(File.dirname(__FILE__), 'versions', file_to_parse + '.rb')

    # require 'pry'
    # binding.pry

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

  def pre_fix_with_context(context)
    require 'pry'
    binding.pry

    # # Get the current version of React Native in your app
    # react = nil
    # context.umbrella_targets.each do |target|
    #   react_spec = target.specs.find { |s| s.name == 'React' || s.name.start_with?('React/') }
    #   react = react_spec if react_spec
    # end

    # # 0.44.1 -> 0_44_1
    # version = react.version.to_s
    # file_to_parse = version.tr('.', '_') + "-" + version
    # path_to_fix = File.join(File.dirname(__FILE__), 'versions', file_to_parse + '.rb')

    # require 'pry'
    # binding.pry

    # if File.exist? path_to_fix
    #   puts "Patching React Native #{version}"
    #   require(path_to_fix)
    # elsif !prefix
    #   # There will probably always be a neeed for the post, but a pre can be ignored
    #   puts "CP-Fix-React-Native does not support #{version} yet, please send PRs to"
    #   puts 'https://github.com/orta/cocoapods-fix-react-native'
    # end
  end
end
