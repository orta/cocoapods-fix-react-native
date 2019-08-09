lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-fix-react-native'
  spec.version       = Time.now.strftime("%Y.%m.%d.%H")
  spec.authors       = ['Orta Therox']
  spec.email         = ['orta.therox@gmail.com']
  spec.description   = "CocoaPods plugin which automates hot-patching React Native"
  spec.summary       = "CocoaPods plugin which automates hot-patching React Native"
  spec.homepage      = 'https://github.com/orta/cocoapods-fix-react-native'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '> 1.3'
  spec.add_development_dependency 'rake'
end
