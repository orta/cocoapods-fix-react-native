require 'molinillo/dependency_graph'

class CocoaPodsFixReactNative
  def post_fix_with_context(context)
    # Get the current version of React Native in your app
    react_spec = nil
    context.umbrella_targets.each do |target|
      react = target.specs.find { |s| s.name == 'React' || s.name.start_with?('React/') }
      next if react.nil?
      react_spec = react
    end

    if react_spec.nil?
      Pod::UI.warn "No React dependency found"
      return
    end

    version = react_spec.version.to_s

    unless patch_exist?(version)
      Pod::UI.warn "CP-Fix-React-Native does not support #{version} yet, please send " +
                   'PRs to https://github.com/orta/cocoapods-fix-react-native'
      return
    end

    path_to_fix = version_file(version)

    if File.exist? path_to_fix
      Pod::UI.section "Post-Patching React Native #{version}" do
        require(path_to_fix)
      end
    end
  end

  def pre_fix_with_context(context)
    version = '0.58.6'

    # There will probably always be a neeed for the post, but a pre can be ignored
    return unless patch_exist?(version)

    path_to_fix = version_file(version, 'pre')

    if File.exist? path_to_fix
      Pod::UI.section "Pre-Patching React Native #{version}" do
        require(path_to_fix)
      end
    end
  end

  private

    def patch_exist?(version)
      version_file_name = version.tr('.', '_')
      patches = Dir.glob(File.join(versions_path, "#{version_file_name}-*"))
      patches.present?
    end

    def version_file(version, suffix = 'post')
      file_to_parse = version.tr('.', '_') + "-#{suffix}.rb"
      File.join(versions_path, file_to_parse)
    end

    def versions_path
      File.expand_path('../versions', __FILE__)
    end
end
