require "attributes_and_token_lists/version"
require "attributes_and_token_lists/engine"
require "attributes_and_token_lists/attributes_builder"

module AttributesAndTokenLists
  mattr_accessor(:config) { ActiveSupport::OrderedOptions.new }

  def self.define(name, &block)
    builder = config.builders[name] = Class.new(AttributesBuilder)

    if block.present?
      block.arity.zero? ? builder.instance_exec(&block) : builder.yield_self(&block)
    end
  end

  def self.define_builder_helper_methods(helpers)
    config.builders.each do |name, builder|
      helpers.define_method name do
        builder.new(self)
      end
    end

    helpers
  end
end
