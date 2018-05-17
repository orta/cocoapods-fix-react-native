# Notes:
#
#  - All file paths should be relative to the React repo, rather than the Pods dir, or node_modules
#  - An enviroment variable of `COCOAPODS_FIX_REACT_NATIVE_DEV_ROOT` will override the defaults for dev.
#
#  - Returns the root directory to use for React Native

def get_root
  # Are you using :path based Pods?
  dev_pods_react = !File.directory?('Pods/React/React')

  # Check for whether we're in a project that uses relative paths
  same_repo_node_modules = File.directory?('node_modules/react-native')
  previous_repo_node_modules = File.directory?('../node_modules/react-native')

  # Find out where the files could be rooted
  $root = 'Pods/React'

  if dev_pods_react
    # Use this as an override, if present and non empty string
    $env_root = ENV["COCOAPODS_FIX_REACT_NATIVE_DEV_ROOT"]

    if defined?($env_root) && ($env_root != nil) && ($env_root != '')
      $root = $env_root
    else
      $root = 'node_modules/react-native' if same_repo_node_modules
      $root = '../node_modules/react-native' if previous_repo_node_modules
    end
  end

  return $root
end