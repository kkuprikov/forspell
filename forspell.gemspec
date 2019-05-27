Gem::Specification.new do |s|
  s.name        = 'forspell'
  s.version     = '0.0.7'
  s.authors     = ['Kirill Kuprikov', 'Victor Shepelev']
  s.email       = 'kkuprikov@gmail.com'

  s.summary     = 'For spelling check'
  s.description = 'Forspell is spellchecker for code and documentation.'\
                  'It uses well-known hunspell tool and dictionary, provides customizable output, '\
                  'and could be easily integrated into CI pipeline.'
  s.license       = 'MIT'

  s.files       = `git ls-files exe lib README.md`.split($RS)
  
  s.homepage    = 'http://github.com/kkuprikov/forspell'
  s.require_paths = ["lib"]
  s.bindir = 'exe'
  s.executables << 'forspell'

  s.required_ruby_version = '>= 2.3.0'
  
  s.add_dependency 'slop', '~> 4.6'
  s.add_dependency 'backports', '~> 3.0'
  s.add_dependency 'kramdown', '~> 2.0'
  s.add_dependency 'kramdown-parser-gfm', '~> 1.0'
  s.add_dependency 'sanitize', '~> 5.0'
  s.add_dependency 'yard'
  s.add_dependency 'ffi-hunspell'
  s.add_dependency 'parser'
  s.add_dependency 'pastel'
  s.add_dependency 'highline'
  s.add_dependency 'ruby-progressbar'

  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'fakefs'
end