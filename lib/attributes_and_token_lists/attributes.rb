require "active_support/core_ext/hash/deep_transform_values"

module AttributesAndTokenLists
  class Attributes # :nodoc:
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
    ].flat_map { |key| [key, key.to_s] }.freeze
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
    ].flat_map { |key| [key, key.to_s] }.freeze

    def self.deep_wrap_token_lists(view_context, attributes)
      attributes.deep_merge(attributes) do |attribute, value|
        if attribute.in?(TOKEN_LIST_ATTRIBUTES | NESTED_TOKEN_LISTS_ATTRIBUTES)
          view_context.token_list(value)
        else
          value
        end
      end
    end

    def initialize(view_context, tag_builder, tag_name = :div, **attributes)
      @view_context = view_context
      @tag_builder = tag_builder
      @attributes = Attributes.deep_wrap_token_lists(view_context, attributes).with_indifferent_access
      @tag_name = tag_name
    end

    def as(tag_name)
      Attributes.new(@view_context, @tag_builder, tag_name, **@attributes)
    end

    def aria(**attributes)
      merge(aria: attributes)
    end

    def data(**attributes)
      merge(data: attributes)
    end

    def merge(other = {})
      other = other.to_h.with_indifferent_access

      attributes = @attributes.merge(other) do |key|
        value, override = @attributes[key], other[key]

        if value.is_a?(Hash) && override.is_a?(Hash)
          Attributes.new(@view_context, @tag_builder).merge(value).merge(override)
        elsif value.respond_to?(:merge)
          value.merge(override)
        else
          override
        end
      end

      Attributes.new(@view_context, @tag_builder, **attributes)
    end
    alias_method :call, :merge
    alias_method :deep_merge, :merge

    def with_attributes(*options, **overrides, &block)
      attributes = [*options, overrides].reduce(self, :merge)

      @view_context.with_attributes(attributes, &block)
    end
    alias_method :with_options, :with_attributes

    def tag(content = nil, **overrides, &block)
      builder = TagBuilder.new(@view_context, @tag_builder, @tag_name, [self])

      if content.present? || overrides.present? || block.present?
        builder.public_send(builder.tag_name, content, **overrides, &block)
      else
        builder
      end
    end

    def to_s
      @tag_builder.attributes(to_hash)
    end

    def to_h
      @attributes.deep_transform_values do |value|
        case value
        when Attributes then value.to_hash
        when TokenList then value.to_s
        else value
        end
      end
    end

    def to_hash
      to_h.deep_symbolize_keys
    end

    def method_missing(name, *arguments, **options, &block)
      receiver =
        if @attributes.respond_to?(name)
          @attributes
        elsif @view_context.respond_to?(name)
          with_attributes
        else
          super
        end

      receiver.public_send(name, *arguments, **options, &block)
    end

    def respond_to_missing?(name, include_private = false)
      @attributes.respond_to?(name) || @view_context.respond_to?(name)
    end

    def inspect
      "#<%<class>s:0x%<addr>08x attributes=%<attributes>s>" %
        {class: self.class, addr: object_id * 2, attributes: @attributes.inspect}
    end
  end
end
