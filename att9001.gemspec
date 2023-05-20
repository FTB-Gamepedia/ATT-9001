Gem::Specification.new do |spec|
	spec.name = "att9001"
	spec.version = "1.0.0"
	spec.authors = ["Eric Schneider (xbony2)"]
	spec.summary = %q{Import Minecraft language files into the tilesheet extension}
	spec.homepage = "https://github.com/FTB-Gamepedia/ATT-9001"
	spec.license = "MIT"

	spec.files = Dir.glob("{lib}/**/*")
	spec.require_paths = ["lib"]

	spec.add_runtime_dependency "mediawiki-butt", "~> 4.0.1"
end
