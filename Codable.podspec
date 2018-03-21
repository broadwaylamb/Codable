#
# Be sure to run `pod lib lint Codable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Codable'
  s.version          = '0.2.0'
  s.summary          = 'A backport of Swift 4 Codable.'

  s.description      = <<-DESC
This library is a backport of the Swift 4 `Codable` stuff. It includes the implementations of the `Codable` protocol for standard types and Foundation types, and `JSONEncoder` and `JSONDecoder` classes as well.
                       DESC

  s.homepage         = 'https://github.com/broadwaylamb/Codable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'broadwaylamb' => 'jaskiewiczs@icloud.com' }
  s.source           = { :git => 'https://github.com/broadwaylamb/Codable.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/broadway_lamb'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.swift_version = '4.0'
  s.default_subspecs = 'Everything'

  s.subspec 'Everything' do |ss|
    ss.source_files = 'Sources/*.swift'
  end

  s.subspec 'BackportJSONEncoder' do |ss|
    ss.source_files = 'Sources/BackportJSONEncoder.swift', 'Sources/FoundationCodable.swift'
  end
end
