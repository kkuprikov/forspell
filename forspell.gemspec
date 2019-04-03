Gem::Specification.new do |s|
  s.name        = 'forspell'
  s.version     = '0.0.3'
  s.authors     = ['Kirill Kuprikov', 'Victor Shepelev']
  s.email       = 'kkuprikov@gmail.com'

  s.summary     = 'For spelling check'
  s.description = 'Forspell is spellchecker for code and documentation.'\
                  'It uses well-known hunspell tool and dictionary, provides customizable output, '\
                  'and could be easily integrated into CI pipeline.'
  s.license       = 'MIT'

  s.files       = `git ls-files exe lib README.md`.split($RS)
  
  s.add_dependency 'slop', '~> 4.6'
  s.add_dependency 'backports', '~> 3.0'

  s.homepage    = 'http://github.com/kkuprikov/forspell'
  s.require_paths = ["lib"]
  s.bindir = 'exe'
  s.executables << 'forspell'
end