Pod::Spec.new do |s|
  s.name         = "Kanagata"
  s.version      = "0.1.2"
  s.summary      = "Kanagata is a JSON decoder and encoder in Swift."
  s.homepage     = "https://github.com/mike-neko/Kanagata"
  s.license      = "MIT"
  s.author             = { "mike-neko" => "mike.app.info@gmail.com" }
  s.social_media_url   = "https://twitter.com/m__ike_"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/mike-neko/Kanagata.git", :tag => "#{s.version}" }
  s.source_files  = "Kanagata/*.swift"
  s.requires_arc = true
end
