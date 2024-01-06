# frozen_string_literal: true

require_relative "lib/logtest/version"

Gem::Specification.new do |spec|
  spec.name = "logtest"
  spec.version = Logtest::VERSION  
  spec.authors = ["Joseph"]
  spec.email = ["joseph9406@hotmail.com"]

  spec.summary = "Write a short summary, because RubyGems requires one."
  spec.description = "Write a longer description or delete this line."
  spec.homepage = "https://rubygems.org/gems/hola"
  spec.license = "MIT"
  #spec.required_ruby_version = ">= 2.6.0"
  
  # 指定你想發佈到那個 host server 上，這個設定讓你可以只允許發佈到私人伺服器上，但如果想要公開發佈到 rubygems，可以這樣填寫
  # spec.metadata["allowed_push_host"] = https://rubygems.org'
  spec.metadata["allowed_push_host"] = "https://github.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://rubygems.org/gems/hola"
  spec.metadata["changelog_uri"] = "https://rubygems.org/gems/hola"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  #spec.files = Dir.chdir(__dir__) do
  #  `git ls-files -z`.split("\x0").reject do |f|
  #    (File.expand_path(f) == __FILE__) ||
  #      f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
  #  end
  #end
  spec.files = Dir.glob("{bin,public,config,views,lib,modules}/**/*")
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

