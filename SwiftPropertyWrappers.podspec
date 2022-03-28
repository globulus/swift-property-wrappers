Pod::Spec.new do |s|
  s.name             = 'SwiftPropertyWrappers'
  s.version          = '1.1.0'
  s.summary          = 'A Collection of useful Swift property wrappers to make coding easier.'
  s.homepage         = 'https://github.com/globulus/swift-property-wrappers'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gordan Glavaš' => 'gordan.glavas@gmail.com' }
  s.source           = { :git => 'https://github.com/globulus/swift-property-wrappers.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '4.0'
  s.source_files = 'Sources/SwiftPropertyWrappers/**/*'
end
