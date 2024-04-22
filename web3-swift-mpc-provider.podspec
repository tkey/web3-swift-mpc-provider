Pod::Spec.new do |spec|
  spec.name         = "web3-mpc-provider-swift"
  spec.version      = "4.0.0"
  spec.ios.deployment_target = '13.0'
  spec.summary      = "MPC TSS Client"
  spec.homepage     = "https://web3auth.io/"
  spec.license      = { :type => 'BSD', :file => 'License.md' }
  spec.swift_version   = "5.0"
  spec.author       = { "Torus Labs" => "hello@tor.us" }
  spec.source       = { :git => "https://github.com/tkey/web3-swift-mpc-provider.git", :tag => spec.version }
  spec.source_files = "Sources/**/*.{swift,h,c}"
  spec.dependency 'web3.swift', '~> 1.6.0'
  spec.dependency 'tssClientSwift', '4.0.0'
  spec.dependency 'curvelib.swift', '~> 1.0.1'
  spec.module_name = "Web3SwiftMpcProvider"
end
