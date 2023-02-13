#
#  Be sure to run `pod spec lint MyFramework.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name               = "XYZHelloWorld"
  spec.swift_version      = "5.3"
  spec.version            = "1.0.11"
  spec.summary            = "Example library"
  spec.description        = "..."
  spec.homepage           = "..."
  spec.documentation_url  = "..."
  spec.license            = { :type => "MIT" }
  spec.author             = { "skrdaz" => "adin.zulia@sangkuriangjayapersada.com" }
  spec.source             = { :git => 'https://github.com/skrdaz/sdk-hello-world-ios.git', :tag => "#{spec.version}" }
  

  # Supported deployment targets
  spec.ios.deployment_target  = "10.0"
  # spec.ios.deployment_target = '11.0'
  spec.ios.vendored_frameworks = "XYZHelloWorld.xcframework"
  spec.dependency 'Alamofire'
  spec.dependency 'SwiftyRSA'
  
  # spec.name               = "XYZHelloWorld"
  # spec.version            = "1.0.2"
  # spec.summary            = "Star Wars Library for iOS apps"
  # spec.description        = "..."
  # spec.homepage           = "..."
  # spec.documentation_url  = "..."
  # spec.license            = { :type => "MIT" }
  # spec.author            = { "skrdaz" => "adin.zulia@sangkuriangjayapersada.com" }
  # spec.source             = { :git => 'https://github.com/skrdaz/sdk-hello-world-ios.git', :tag => "#{spec.version}" }
  # spec.swift_version      = "5.3"

  # # Supported deployment targets
  # spec.ios.deployment_target  = "10.0"

  # # Published binaries
  # vendored_frameworks = "XYZHelloWorld.xcframework"

  # spec.name         = "XYZHelloWorld"
  # spec.version      = "1.0.0"
  # spec.summary      = "A short description of XYZHelloWorld."
  # spec.description  = "A complete description of XYZHelloWorld"

  # spec.platform     = :ios, "12.0"

  # spec.homepage     = "http://EXAMPLE/XYZHelloWorld"
  # spec.license      = "MIT"
  # spec.author       = { "skrdaz" => "adin.zulia@sangkuriangjayapersada.com" }
  # spec.source       = { :git => "https://github.com/skrdaz/sdk-hello-world-ios.git", :tag => "1.0.0" }
  # spec.ios.vendored_frameworks = 'XYZHelloWorld.xcframework'

  
  # spec.source_files  = "XYZHelloWorld"
  # spec.exclude_files = "Classes/Exclude"
  # spec.swift_version = "5.0" 
  # spec.dependency 'Alamofire'
  # spec.dependency = 'Alamofire', '5.0.0-beta.3'
  # spec.dependency 'Alamofire', "= 5.0.0-beta.3"
  # pec.dependency 'Alamofire', '5.0.0-beta.3'
end
