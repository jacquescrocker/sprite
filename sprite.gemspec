Gem::Specification.new do |s|
  s.name = "sprite"
  s.version = "0.2.3"

  s.executables = ["sprite"]

  s.authors = ["Jacques Crocker", "Alf Mikula"]
  s.summary = "generate your css and sass sprites automagically"
  s.description = "sprite is a ruby executable that to easily generate sprites along with css, sass"

  s.email = "railsjedi@gmail.com"
  s.homepage = "http://github.com/railsjedi/sprite"
  s.rubyforge_project = "none"

  s.require_paths = ["lib"]
  s.files = Dir['bin/*',
                'lib/**/*',
                'MIT-LICENSE',
                'rails/**/*',
                'Rakefile',
                'README.md',
                'spec/**/*',
                'tasks/**/*',
                'sprite.gemspec',
                'Gemfile',
                'Gemfile.lock']

  s.test_files = Dir['spec/**/*']
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = [
    "MIT-LICENSE",
    "README.md"
  ]

  s.add_development_dependency "rspec", "~> 2.0"
end