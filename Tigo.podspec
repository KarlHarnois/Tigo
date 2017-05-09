Pod::Spec.new do |s|
    s.name         = "Tigo"
    s.version      = "0.0.1"
    s.summary      = "A dead simple reactive library."
    s.description  = "Tigo is a small opinionated library heavily inspired from RxSwift and ReactiveCocoa."
    s.homepage     = "https://github.com/KarlHarnois/Tigo"
    s.license      = { :type => "MIT", :file => "license" }
    s.author       = { "Karl Rivest Harnois" => "karlrivestharnois@gmail.com" }
    s.platform     = :ios, "10.2"
    s.source       = { :git => "https://github.com/KarlHarnois/Tigo.git", :tag => "#{s.version}" }
    s.source_files  = "Tigo/**/*.swift"
end
