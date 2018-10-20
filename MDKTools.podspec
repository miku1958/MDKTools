

Pod::Spec.new do |s|


  s.name         = "MDKTools"
  s.version      = "1.0.2"
  s.summary      = "a tools"


  s.description  = <<-DESC
a  tools 
                   DESC

  s.homepage     = "https://github.com/miku1958/MDKTools"

  s.license      = "Mozilla"


  s.author             = { "miku1958" => "email@address.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/miku1958/MDKTools.git", :tag => "#{s.version}" }



    s.subspec 'swift' do |swift|
    swift.source_files = 'Swift/*.{swift}'
    end


  s.swift_version = '4.0'
  s.requires_arc = true


end
