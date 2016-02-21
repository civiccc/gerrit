$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'gerrit/constants'
require 'gerrit/version'

Gem::Specification.new do |s|
  s.name             = 'gerrit'
  s.version          = Gerrit::VERSION
  s.license          = 'MIT'
  s.summary          = 'Gerrit command line interface'
  s.description      = 'Tool providing an effective CLI workflow with Gerrit'
  s.authors          = ['Shane da Silva']
  s.email            = ['shane@dasilva.io']
  s.homepage         = Gerrit::REPO_URL

  s.require_paths    = ['lib']

  s.executables      = ['gerrit']

  s.files            = Dir['lib/**/*.rb']

  s.required_ruby_version = '>= 2.1'

  s.add_dependency 'childprocess', '~> 0.5.6'
  s.add_dependency 'parallel', '~> 1.6.0'
  s.add_dependency 'pry', '~> 0.10'
  s.add_dependency 'tty', '~> 0.2.0'
end
