class ReactDependencyVersion
  def fix_with_context(context)
    all_pods_targets = context.pods_project.targets
    all_pods_targets.each do |t|
      deployment_target = t.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
      has_react_dep =  t.dependencies.find { |dep| dep.name == 'React' }

      if has_react_dep && deployment_target == '4.3'
        raise 'You have a Pod which has a deployment target of 4.3, and a dependency on React.' \
              "\nIn order for React Native to compile you need to give the Podspec for #{t.name} a version like `s.platform = :ios, '9.0'`.\n"
      end
    end
  end
end
