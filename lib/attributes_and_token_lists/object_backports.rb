require "active_support/core_ext/object/with_options"

module AttributesAndTokenLists::ObjectBackports
  extend ActiveSupport::Concern

  included do
    alias_method :__original_with_options, :with_options

    def with_options(options, &block)
      if block.nil?
        options_merger = nil
        __original_with_options(options) { |object| options_merger = object }
        options_merger
      else
        __original_with_options(options, &block)
      end
    end
  end
end
