Gem::Specification.new do |spec|
  spec.name          = "att9001"
  spec.version       = "0.1.0"
  spec.authors       = ["Xbony2"]
  spec.summary       = %q{Import Minecraft language files into the tilesheet extension}
  spec.homepage      = "https://ftb.fandom.com/wiki/Feed_The_Beast_Wiki:ATT-9001"
  spec.license       = "MIT"

  spec.files         = Dir.glob("{lib}/**/*")
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mediawiki-butt", "~> 4.0.1"
end

