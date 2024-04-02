#
# Be sure to run `pod lib lint JkQRScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JkQRScanner'
  s.version          = '0.1.0'
  s.summary          = 'A SWIFT library that enable user to implement QR scanner in whatever UIView they want'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  "JkQRScanner is a Swift 5-based custom QR Scanner designed to be compatible with iOS versions 13.0 and higher."
                       DESC

  s.homepage         = 'https://github.com/jaykothadia28/JkQRScanner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jay Kothadia' => 'jay.kothadia@gmail.com' }
  s.source           = { :git => 'https://github.com/jaykothadia28/JkQRScanner.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.source_files = 'Classes/**/*'
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  
  # s.resource_bundles = {
  #   'JkQRScanner' => ['JkQRScanner/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
