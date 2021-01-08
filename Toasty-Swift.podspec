Pod::Spec.new do |s|
    s.name             = 'Toasty-Swift'
    s.version          = '1.0.0'
    s.summary          = 'A toast framework with swift for iOS.'

    s.homepage         = 'https://github.com/yangjie2/Toasty'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'yangjie' => 'yangjie2107@qq.com'}
    s.source           = { :git => 'https://github.com/yangjie2/Toasty.git', :tag => s.version.to_s }

    s.platform     = :ios, '9.0'    
    s.frameworks   = 'UIKit', 'Foundation'

    s.source_files = "Toasty/*.{swift, h}"
    
end
