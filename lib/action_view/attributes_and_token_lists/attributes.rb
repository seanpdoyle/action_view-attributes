require "active_support/core_ext/hash/deep_transform_values"

module ActionView
  module AttributesAndTokenLists
    class Attributes #:nodoc:
      delegate_missing_to :@attributes

      TOKEN_LIST_ATTRIBUTES = %i[
        class
        rel
        data-action
        data-controller
        aria-controls
        aria-flowto
        aria-describedby
        aria-labelledby
        aria-owns
        aria-dropeffect
        aria-relevant
      ].flat_map { |key| [ key, key.to_s ] }.freeze
      NESTED_TOKEN_LISTS_ATTRIBUTES = %i[
        action
        controller
        controls
        flowto
        describedby
        labelledby
        owns
        dropeffect
        relevant
      ].flat_map { |key| [ key, key.to_s ] }.freeze

      def self.deep_wrap_token_lists(attributes)
        attributes.deep_merge(attributes) do |attribute, value|
          if attribute.in?(TOKEN_LIST_ATTRIBUTES | NESTED_TOKEN_LISTS_ATTRIBUTES)
            ActionView::AttributesAndTokenLists::TokenList.wrap(ActionView::Helpers::TagHelper.build_tag_values(value))
          else
            value
          end
        end
      end

      def initialize(tag_builder, view_context, attributes)
        @tag_builder = tag_builder
        @view_context = view_context
        @attributes = Attributes.deep_wrap_token_lists(attributes).with_indifferent_access
      end

      def merge(other)
        other = other.to_hash.with_indifferent_access

        attributes = @attributes.merge(other) do |key|
          value, override = @attributes[key], other[key]

          if value.is_a?(Hash) && override.is_a?(Hash)
            Attributes.new(@tag_builder, @view_context, value).merge(override).to_hash
          elsif value.respond_to?(:merge)
            value.merge(override)
          else
            value
          end
        end

        Attributes.new(@tag_builder, @view_context, attributes)
      end
      alias_method :+, :merge
      alias_method :|, :merge
      alias_method :deep_merge, :merge

      def with_attributes(options, &block)
        @view_context.with_attributes(**merge(options), &block)
      end
      alias_method :with_options, :with_attributes

      def tag
        AttributeMerger.new(@view_context, @view_context.tag, self)
      end

      def to_s
        html_ready_attributes = @attributes.transform_values do |value|
          case value
          when Attributes then value.to_hash
          when TokenList then value.to_a
          else value
          end
        end

        @tag_builder.tag_options(html_ready_attributes).to_s.strip.html_safe
      end

      def inspect
        "#<%<class>s:0x%<addr>08x attributes=%<attributes>s>" %
          { class: self.class, addr: object_id * 2, attributes: @attributes.inspect }
      end
    end
  end
end
