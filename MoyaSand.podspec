#
# Be sure to run `pod lib lint MoyaSand.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MoyaSand'
  s.version          = '0.0.2'
  s.summary          = 'Moya extensions for moving parsing logic out of completion blocks.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MoyaSand works with the Moya networking abstraction framework to encapsulate the final steps and do parsing of the response before invoking completion blocks. This can keep the call site decluttered, as well as let the TargetType always specify how to parse calls to its endpoint.
                       DESC

  s.homepage         = 'https://github.com/mike-sand/MoyaSand'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mike-sand' => 'git@mikesand.com' }
  s.source           = { :git => 'https://github.com/mike-sand/MoyaSand.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/_mikesand'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MoyaSand/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MoyaSand' => ['MoyaSand/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Moya'
end
