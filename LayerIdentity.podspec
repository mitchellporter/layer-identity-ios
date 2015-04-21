#
# Be sure to run `pod lib lint LayerUIKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LayerIdentity"
  s.version          = "0.1.0"
  s.summary          = "A simple library to request identity tokens from the Layer Identity Provider."
  s.license          = 'Apache'
  s.author           = { "Kevin Coleman" => "kevin@layer.com" }
  s.source           = { :git => "https://github.com/layerhq/layer-auth-ios.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'Code'

  s.ios.frameworks = 'UIKit'
  s.ios.deployment_target = '7.0'
  
end
