# Notes:
#
#  - All file paths should be relative to the React repo, rather than the Pods dir, or node_modules
#

# Are you using :path based Pods?
dev_pods_react = !File.directory?('Pods/React/React')

# Check for whether
same_repo_node_modules = File.directory?('node_modules/react-native')
previous_repo_node_modules = File.directory?('../node_modules/react-native')

# Find out where the files could be rooted
$root = 'Pods/React'
if dev_pods_react
  $root = 'node_modules/react-native' if same_repo_node_modules
  $root = '../node_modules/react-native' if previous_repo_node_modules
end

# TODO: move to be both file in pods and file in node_mods?
def edit_pod_file(path, old_code, new_code)
  file = File.join($root, path)
  code = File.read(file)
  if code.include?(old_code)
    FileUtils.chmod('+w', file)
    File.write(file, code.sub(old_code, new_code))
  end
end

def fix_cplusplus_header_compiler_error
  filepath = File.join($root, 'React/Base/Surface/SurfaceHostingView/RCTSurfaceSizeMeasureMode.h')
  FileUtils.chmod('+w', filepath)

  contents = []

  file = File.open(filepath, 'r')
  file.each_line do |line|
    contents << line
  end
  file.close

  if contents[32].include? '&'
    contents.insert(26, '#ifdef __cplusplus')
    contents[36] = '#endif'

    file = File.open(filepath, 'w') do |f|
      f.puts(contents)
    end
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
    contents.delete_at(15) # #import "YGNode.h"
    contents.delete_at(15) # #import "YGNodePrint.h"
    contents.delete_at(15) # #import "Yoga-internal.h"
    contents.delete_at(12) # #import "Utils.h"

    file = File.open(filepath, 'w') do |f|
      f.puts(contents)
    end
  end
end

# Detect CocoaPods + Frameworks
def has_frameworks
  filepath = 'Pods/Target Support Files/React/React-umbrella.h'
  return File.exists?(filepath)
end

def fix_method_queue_property_defs
  return if has_frameworks

  # Newer build of Xcode don't allow you to set a non-obj to be strong,
  # so this instead changes it to be an assign.
  module_data_file = 'React/Base/RCTModuleData.h'
  bridge_module_file = 'React/Base/RCTBridgeModule.h'
  method_queue_old_code = '(nonatomic, strong, readonly) dispatch_queue_t methodQueue'
  method_queue_new_code = '(nonatomic, assign, readonly) dispatch_queue_t methodQueue'
  edit_pod_file module_data_file, method_queue_old_code, method_queue_new_code
  edit_pod_file bridge_module_file, method_queue_old_code, method_queue_new_code
end

fix_unused_yoga_headers
fix_cplusplus_header_compiler_error
fix_method_queue_property_defs

# https://github.com/facebook/react-native/pull/14664
animation_view_file = 'Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h'
animation_view_old_code = 'import <RCTAnimation/RCTValueAnimatedNode.h>'
animation_view_new_code = 'import "RCTValueAnimatedNode.h"'
edit_pod_file animation_view_file, animation_view_old_code, animation_view_new_code

# https://github.com/facebook/react-native/issues/13198
# Only needed when you have the DevSupport subspec
has_dev_support = File.exist?(File.join($root, 'Libraries/WebSocket/RCTReconnectingWebSocket.m'))

if has_dev_support
  # Move Fishhook to be based on RN's imports
  websocket = 'Libraries/WebSocket/RCTReconnectingWebSocket.m'
  websocket_old_code = 'import <fishhook/fishhook.h>'
  websocket_new_code = 'import <React/fishhook.h>'
  edit_pod_file websocket, websocket_old_code, websocket_new_code
else
  # There's a link in the DevSettings to dev-only import
  dev_settings = 'React/Modules/RCTDevSettings.mm'
  dev_settings_old_code = '#import "RCTPackagerClient.h"'
  dev_settings_new_code = '//#import //"RCTPackagerClient.h"'
  edit_pod_file dev_settings, dev_settings_old_code, dev_settings_new_code
end
