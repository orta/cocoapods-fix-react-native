require 'cocoapods'
require 'cocoapods-fix-react-native/helpers/root_helper'

# Obtain the React Native root directory
$root = get_root

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

# https://github.com/facebook/react-native/pull/23274
react_podspec_file = 'React.podspec'
react_podspec_old_code = '
  s.subspec "jsiexecutor" do |ss|
    ss.dependency             "React/cxxreact"
    ss.dependency             "React/jsi"
    ss.dependency             "Folly", folly_version
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "ReactCommon/jsiexecutor/jsireact/*.{cpp,h}"
    ss.private_header_files = "ReactCommon/jsiexecutor/jsireact/*.h"
    ss.header_dir           = "jsireact"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/ReactCommon\"" }
  end
'
react_podspec_new_code = '
s.subspec "jsiexecutor" do |ss|
    ss.dependency             "React/cxxreact"
    ss.dependency             "React/jsi"
    ss.dependency             "Folly", folly_version
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "ReactCommon/jsiexecutor/jsireact/*.{cpp,h}"
    ss.private_header_files = "ReactCommon/jsiexecutor/jsireact/*.h"
    ss.header_dir           = "jsireact"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/ReactCommon\", \"$(PODS_TARGET_SRCROOT)/ReactCommon/jsiexecutor\"" }
  end
'
patch_pod_file react_podspec_file, react_podspec_old_code, react_podspec_new_code
