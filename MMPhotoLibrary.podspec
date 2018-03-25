#
# Be sure to run `pod lib lint MMPhotoLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMPhotoLibrary'
  s.version          = '0.1.0'
  s.summary          = 'A short summury of MMPhotoLibrary.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A short description of MMPhotoLibrary.'

  s.homepage         = 'https://github.com/moosamir68/MMPhotoLibrary'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Moosa Mir' => 'moosamir68@gmail.com' }
  s.source           = { :git => 'https://github.com/moosamir68/MMPhotoLibrary.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'MMPhotoLibrary/Classes/**/*'

  s.resource = ['MMPhotoLibrary/Assests.xcassets',  'MMPhotoLibrary/Classes/*.xib']

#   s.resource_bundles = {
#       'MMPhotoLibrary' => ['Assests.xcassets/*.imageset/*.png','Classes/*.xib']
#}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'TOCropViewController', '~> 2.3.4'
  s.dependency 'KTCenterFlowLayout', '~> 1.3.1'
  s.dependency 'SnapKit', '~> 4.0.0'


end
