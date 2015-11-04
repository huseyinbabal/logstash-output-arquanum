Gem::Specification.new do |s|

  s.name            = 'logstash-output-arquanum'
  s.version         = '1.0.0'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = "Redirect your logs to arquanum to analyze your logs"
  s.description     = "Arquanum Logstash Plugin can be installed within your current logstash installation."
  s.authors         = ["Arquanum"]
  s.email           = 'info@arquanum.com'
  s.homepage        = "http://www.arquanum.com/guide/en/plugins/arquanum"
  s.require_paths   = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0.rc1", "< 3.0.0"
  s.add_runtime_dependency "httparty", "~> 0.13.7"
  s.add_development_dependency 'logstash-devutils', '~> 0.0.18'
  s.add_development_dependency 'logstash-codec-plain', '~> 2.0', '>= 2.0.2'
end
