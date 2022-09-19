Pod::Spec.new do |s|
  s.name             = 'Acorn'
  s.version          = '1.0.2'
  s.platform         = :ios
  s.ios.deployment_target = '13.0'
  s.summary          = 'Acorn helps to download and cache Image'
  s.swift_version    = '5.0'
  s.homepage         = 'https://github.com/jeon-soyeong/Acorn'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'So Yeong Jeon' => 'jsu3417@gmail.com' }
  s.source           = { :git => 'https://github.com/jeon-soyeong/Acorn.git', :tag => s.version }
  s.source_files     = 'Acorn/Acorn/Sources/*.swift', 'Acorn/Acorn/Sources/*/*.swift'
end