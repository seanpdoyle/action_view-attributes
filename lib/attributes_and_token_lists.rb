require "attributes_and_token_lists/version"
require "attributes_and_token_lists/engine"
require "attributes_and_token_lists/tag_builder"

module AttributesAndTokenLists
  mattr_accessor(:config) { ActiveSupport::OrderedOptions.new }

  def self.builder(name, &block)
    instance = config.builders[name] = Class.new(TagBuilder)

    if block.present?
      block.arity.zero? ? instance.instance_exec(&block) : instance.yield_self(&block)
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
