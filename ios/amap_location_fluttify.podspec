#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'amap_location_fluttify'
  s.version          = '0.0.1'
  s.summary          = 'An `Amap` Location Component, Powered By `Fluttify`, A Compiler Generating Dart Bindings For Native SDK.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/fluttify-project/amap_location_fluttify'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'yohom' => 'yohombao@qq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = ['Classes/**/*.h', 'Vendors/*.h']
  s.dependency 'Flutter'
  s.dependency 'foundation_fluttify'
  s.dependency 'amap_core_fluttify'
  s.dependency 'AMapLocation-NO-IDFA', '~> 2.9.0'

  s.static_framework = true
  s.ios.deployment_target = '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.vendored_frameworks = 'Vendors/*.framework'
  s.vendored_libraries = 'Vendors/*.a'
  s.frameworks = [
        
  ]
  s.libraries = [
        
  ]
  s.resources = 'Vendors/**/*.bundle'
end
