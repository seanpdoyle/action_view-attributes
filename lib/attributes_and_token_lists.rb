require "attributes_and_token_lists/version"
require "attributes_and_token_lists/engine"
require "attributes_and_token_lists/configuration"
require "attributes_and_token_lists/builder"

module AttributesAndTokenLists
  mattr_accessor :builders, default: {}

  def self.html_attributes(name, view_context = Module.new, &block)
    builders[name] = Configuration.new(name, &block)

    view_context.define_method(name) { Builder.new(builders[name], self) }

    view_context
  end
end
