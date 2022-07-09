require_relative "lib/attributes_and_token_lists/version"

Gem::Specification.new do |spec|
  spec.name = "attributes_and_token_lists"
  spec.version = AttributesAndTokenLists::VERSION
  spec.authors = ["Sean Doyle"]
  spec.email = ["sean.p.doyle24@gmail.com"]
  spec.homepage = "https://github.com/seanpdoyle/attributes_and_token_lists"
  spec.summary = "Change Action View's `token_lists` and `class_names` helpers to return instances
of `TokenList`, and `tag.attributes` helpers to return instances of
`Attributes`."
  spec.description = spec.summary
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/seanpdoyle/attributes_and_token_lists"
  spec.metadata["changelog_uri"] = "https://github.com/seanpdoyle/attributes_and_token_lists/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.1.3.1"
end
