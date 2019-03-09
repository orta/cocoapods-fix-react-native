require_relative './0_58_4-pre'

# https://github.com/facebook/react-native/pull/23430
react_podspec_file = 'React.podspec'

# Patch jsiexecutor
react_podspec_jsiexecutor_old_code = '
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
react_podspec_jsiexecutor_new_code = '
  s.subspec "jsiexecutor" do |ss|
    ss.dependency             "React/cxxreact"
    ss.dependency             "React/jsi"
    ss.dependency             "Folly", folly_version
    ss.dependency             "DoubleConversion"
    ss.dependency             "glog"
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "ReactCommon/jsiexecutor/jsireact/*.{cpp,h}"
    ss.private_header_files = "ReactCommon/jsiexecutor/jsireact/*.h"
    ss.header_dir           = "jsireact"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/ReactCommon\", \"$(PODS_TARGET_SRCROOT)/ReactCommon/jsiexecutor\"" }
  end
'
patch_pod_file react_podspec_file, react_podspec_jsiexecutor_old_code, react_podspec_jsiexecutor_new_code

# Patch jsi
react_podspec_jsi_old_code = '
  s.subspec "jsi" do |ss|
    ss.dependency             "Folly", folly_version
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "ReactCommon/jsi/*.{cpp,h}"
    ss.private_header_files = "ReactCommon/jsi/*.h"
    ss.framework            = "JavaScriptCore"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/ReactCommon\"" }
  end
'
react_podspec_jsi_new_code = '
  s.subspec "jsi" do |ss|
    ss.dependency             "Folly", folly_version
    ss.dependency             "DoubleConversion"
    ss.dependency             "glog"
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "ReactCommon/jsi/*.{cpp,h}"
    ss.private_header_files = "ReactCommon/jsi/*.h"
    ss.framework            = "JavaScriptCore"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/ReactCommon\"" }
  end
'
patch_pod_file react_podspec_file, react_podspec_jsi_old_code, react_podspec_jsi_new_code

# Patch cxxreact
react_podspec_cxxreact_old_code = '
  s.subspec "cxxreact" do |ss|
    ss.dependency             "React/jsinspector"
    ss.dependency             "boost-for-react-native", "1.63.0"
    ss.dependency             "Folly", folly_version
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "ReactCommon/cxxreact/*.{cpp,h}"
    ss.exclude_files        = "ReactCommon/cxxreact/SampleCxxModule.*"
    ss.private_header_files = "ReactCommon/cxxreact/*.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/ReactCommon\" \"$(PODS_ROOT)/boost-for-react-native\" \"$(PODS_ROOT)/DoubleConversion\" \"$(PODS_ROOT)/Folly\"" }
  end
'
react_podspec_cxxreact_new_code = '
  s.subspec "cxxreact" do |ss|
    ss.dependency             "React/jsinspector"
    ss.dependency             "boost-for-react-native", "1.63.0"
    ss.dependency             "Folly", folly_version
    ss.dependency             "DoubleConversion"
    ss.dependency             "glog"
    ss.compiler_flags       = folly_compiler_flags
    ss.source_files         = "ReactCommon/cxxreact/*.{cpp,h}"
    ss.exclude_files        = "ReactCommon/cxxreact/SampleCxxModule.*"
    ss.private_header_files = "ReactCommon/cxxreact/*.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/ReactCommon\" \"$(PODS_ROOT)/boost-for-react-native\" \"$(PODS_ROOT)/DoubleConversion\" \"$(PODS_ROOT)/Folly\"" }
  end
'
patch_pod_file react_podspec_file, react_podspec_cxxreact_old_code, react_podspec_cxxreact_new_code
