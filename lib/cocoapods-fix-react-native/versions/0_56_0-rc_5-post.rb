require 'cocoapods'
require 'cocoapods-fix-react-native/helpers/root_helper'

# Obtain the React Native root directory
$root = get_root

# Detect CocoaPods + Frameworks
$has_frameworks = File.exists?'Pods/Target Support Files/React/React-umbrella.h'

# TODO: move to be both file in pods and file in node_mods?
def patch_pod_file(path, old_code, new_code)
  file = File.join($root, path)
  unless File.exist?(file)
    Pod::UI.warn "#{file} does not exist so was not patched.."
    return
  end
  code = File.read(file)
  if code.include?(old_code)
    Pod::UI.message "Patching #{file}", '- '
    FileUtils.chmod('+w', file)
    File.write(file, code.sub(old_code, new_code))
  end
end

def fix_unused_yoga_headers
  filepath = 'Pods/Target Support Files/yoga/yoga-umbrella.h'
  # This only exists when using CocoaPods + Frameworks
  return unless File.exists?(filepath)

  contents = []
  file = File.open(filepath, 'r')
  file.each_line do |line|
    contents << line
  end
  file.close

  if contents[12].include? 'Utils.h'
    Pod::UI.message "Patching #{filepath}", '- '
    contents.delete_at(14) # #import "YGLayout.h"
    contents.delete_at(15) # #import "YGNode.h"
    contents.delete_at(15) # #import "YGNodePrint.h"
    contents.delete_at(15) # #import "YGStyle.h"
    contents.delete_at(15) # #import "Yoga-internal.h"
    contents.delete_at(12) # #import "Utils.h"

    file = File.open(filepath, 'w') do |f|
      f.puts(contents)
    end
  end
end

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

fix_unused_yoga_headers
detect_missing_subspecs

# # https://github.com/facebook/react-native/pull/14664
animation_view_file = 'Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h'
animation_view_old_code = 'import <RCTAnimation/RCTValueAnimatedNode.h>'
animation_view_new_code = 'import "RCTValueAnimatedNode.h"'
patch_pod_file animation_view_file, animation_view_old_code, animation_view_new_code
