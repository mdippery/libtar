Pod::Spec.new do |s|
  s.name         = "Pitch"
  s.version      = "0.1.0"
  s.summary      = "An Objective-C interface to libtar"
  s.homepage     = "https://github.com/mdippery/libtar"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Michael Dippery" => "michael@monkey-robot.com" }
  s.platform     = :osx, "10.6"
  s.source       = { :git => "https://github.com/mdippery/libtar.git", :tag => "v0.1.0" }
  s.source_files = "libpitch", "libtar"

  s.requires_arc = false
end
