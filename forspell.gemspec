Gem::Specification.new do |s|
  s.name        = 'forspell'
  s.version     = '0.0.1'
  s.authors     = ["Kirill Kuprikov"]
  s.email       = 'kkuprikov@gmail.com'

  s.summary     = "For spelling check"
  s.license       = 'MIT'

  s.files       = `git ls-files exe lib README.md`.split($RS)
  s.homepage    = 'http://github.com/kkuprikov/forspell'
  s.require_paths = ["lib"]
  s.bindir = 'exe'
  s.executables << 'forspell'
end