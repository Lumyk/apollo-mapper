#
# Be sure to run `pod lib lint apollo-mapper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'apollo-mapper'
  s.version          = `git describe --abbrev=0 --tags`
  s.summary          = 'Library for mapping swift apollo snapshots to your own class'
  s.description      = 'Library for mapping swift apollo snapshots to your own class, also you can use it for another different mappings'
  s.homepage         = 'https://github.com/lumyk/apollo-mapper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Evgeny Kalashnikov' => 'lumyk@me.com' }
  s.source           = { :git => 'https://github.com/lumyk/apollo-mapper.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/**/*'
end
