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
      Pod::UI.section "Patching React Native #{version}" do
        require(path_to_fix)
      end
    end
  end

  def pre_fix_with_context(context)
    # Get the current version of React Native in your app
    locked_dependencies = Molinillo::DependencyGraph.new
    if context.lockfile
      context.lockfile.dependencies.each do |dependency|
        locked_dependencies.add_vertex(dependency.name, dependency, true)
      end
    else
      Pod::UI.warn 'No Podfile.lock present. Continuing without locked dependencies.'
    end

    sources = context.podfile.sources.map do |source|
      Pod::Config.instance.sources_manager.source_with_name_or_url(source)
    end

    react_spec = nil
    
    begin
      resolver = Pod::Resolver.new(context.sandbox, context.podfile, locked_dependencies, sources, true)
      target_definitions = resolver.resolve

      target_definitions.each do |(definition, dependencies)|
        next if definition.name == 'Pods'

        react = dependencies.find { |d| d.spec.name == 'React' || d.spec.name.start_with?('React/') }
        next if react.nil?
        react_spec = react.spec
      end
    rescue StandardError => e
      Pod::UI.warn 'Failed to resolve dependencies, so pre-patch was not applied, ' +
                   'please try running `pod install` again to apply the patch.'
    end

    return if react_spec.nil?

    version = react_spec.version.to_s

    # There will probably always be a neeed for the post, but a pre can be ignored
    return unless patch_exist?(version)

    path_to_fix = version_file(version, 'pre')

    if File.exist? path_to_fix
      Pod::UI.section "Patching React Native #{version}" do
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
