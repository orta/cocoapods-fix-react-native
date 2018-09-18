require 'cocoapods'
require 'cocoapods-fix-react-native/helpers/root_helper'

# Obtain the React Native root directory
$root = get_root

# Detect CocoaPods + Frameworks
$has_frameworks = File.exists?'Pods/Target Support Files/React/React-umbrella.h'

# Detect source file dependency in the generated Pods.xcodeproj workspace sub-project
def has_pods_project_source_file(source_filename)
  pods_project = 'Pods/Pods.xcodeproj/project.pbxproj'
  File.open(pods_project).grep(/#{source_filename}/).any?
end

# Detect dependent source file required for building when the given source file is present
def meets_pods_project_source_dependency(source_filename, dependent_source_filename)
  has_pods_project_source_file(source_filename) ? has_pods_project_source_file(dependent_source_filename) : true
end

def detect_missing_subspec_dependency(subspec_name, source_filename, dependent_source_filename)
  unless meets_pods_project_source_dependency(source_filename, dependent_source_filename)
    Pod::UI.warn "#{subspec_name} subspec may be required given your current dependencies"
  end
end

def detect_missing_subspecs
  return unless $has_frameworks

  # For CocoaPods + Frameworks, RCTNetwork and CxxBridge subspecs are necessary for DevSupport.
  # When the React pod is generated it must include all the required source, and see umbrella deps.
  detect_missing_subspec_dependency('RCTNetwork', 'RCTBlobManager.mm', 'RCTNetworking.mm')
  detect_missing_subspec_dependency('CxxBridge', 'RCTJavaScriptLoader.mm', 'RCTCxxBridge.mm')

  # RCTText itself shouldn't require DevSupport, but it depends on Core -> RCTDevSettings -> RCTPackagerClient
  detect_missing_subspec_dependency('DevSupport', 'RCTDevSettings.mm', 'RCTPackagerClient.m')
end

detect_missing_subspecs
