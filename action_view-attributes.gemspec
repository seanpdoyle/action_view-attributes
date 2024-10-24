Gem::Specification.new do |spec|
  spec.name = "action_view-attributes"
  spec.version = "0.2.0"
  spec.authors = ["Sean Doyle"]
  spec.email = ["sean.p.doyle24@gmail.com"]
  spec.homepage = "https://github.com/seanpdoyle/action_view-attributes"
  spec.summary = "Extend Action View helpers"
  spec.description = spec.summary
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/seanpdoyle/action_view-attributes"
  spec.metadata["changelog_uri"] = "https://github.com/seanpdoyle/action_view-attributes/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 7.1.0"
end
