require 'cocoapods'

# Notes:
#
#  - All file paths should be relative to the React repo, rather than the Pods dir, or node_modules
#

# Are you using :path based Pods?
dev_pods_react = !File.directory?('Pods/React/React')

# Detect CocoaPods + Frameworks
$has_frameworks = File.exist?('Pods/Target Support Files/React/React-umbrella.h')

# Check for whether we're in a project that uses relative paths
same_repo_node_modules = File.directory?('node_modules/react-native')
previous_repo_node_modules = File.directory?('../node_modules/react-native')

# Find out where the files could be rooted
$root = 'Pods/React'
if dev_pods_react
  $root = 'node_modules/react-native' if same_repo_node_modules
  $root = '../node_modules/react-native' if previous_repo_node_modules
end

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
  return unless File.exist?(filepath)

  contents = []
  file = File.open(filepath, 'r')
  file.each_line do |line|
    contents << line
  end
  file.close

  if contents[14].include? 'YGNode.h'
    Pod::UI.message "Patching #{filepath}", '- '
    contents.delete_at(14) # #import "YGNode.h"
    contents.delete_at(14) # #import "YGNodePrint.h"
    contents.delete_at(14) # #import "Yoga-internal.h"

    file = File.open(filepath, 'w') do |f|
      f.puts(contents)
    end
  end
end

fix_unused_yoga_headers

# https://github.com/facebook/react-native/pull/14664
animation_view_file = 'Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h'
animation_view_old_code = 'import <RCTAnimation/RCTValueAnimatedNode.h>'
animation_view_new_code = 'import "RCTValueAnimatedNode.h"'
patch_pod_file animation_view_file, animation_view_old_code, animation_view_new_code

# https://github.com/facebook/react-native/issues/13198
# Only needed when you have the DevSupport subspec
has_dev_support = File.exist?(File.join($root, 'Libraries/WebSocket/RCTReconnectingWebSocket.m'))

# Move Fishhook to be based on RN's imports
websocket = 'Libraries/WebSocket/RCTReconnectingWebSocket.m'
websocket_old_code = 'import <fishhook/fishhook.h>'
websocket_new_code = 'import <React/fishhook.h>'
patch_pod_file websocket, websocket_old_code, websocket_new_code
