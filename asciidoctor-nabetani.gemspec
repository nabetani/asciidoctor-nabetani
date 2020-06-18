require_relative 'lib/asciidoctor/nabetani/version'

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-nabetani"
  spec.version       = Asciidoctor::Nabetani::VERSION
  spec.authors       = ["Nabetani"]
  spec.email         = ["takenori@nabetani.sakura.ne.jp"]

  spec.summary       = %q{An assortment of things I needed to make a Japanese PDF document with asciidoctor.}
  spec.homepage      = "https://github.com/nabetani/asciidoctor-nabetani"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
