class AttributesAndTokenLists::ViewContext
  class VariantCollisionError < StandardError
  end

  delegate :to_h, :to_hash, :to_s, to: :@attributes

  def initialize(view_context, tag_name = :div, variants: {}, default_variants: {}, **defaults)
    @view_context = view_context
    @tag_name = tag_name.to_sym
    @variants = variants
    @default_variants = default_variants
    @attributes = view_context.tag.attributes(@variants.delete(:defaults), defaults)

    variants.each_key { |key| raise_collision!(key) if respond_to?(key) }
  end

  def merge!(...)
    tap { @attributes.merge!(...) }
  end

  def merge(...)
    dup.merge!(...)
  end
  alias_method :call, :merge

  ruby2_keywords def tag(*arguments, &block)
    if arguments.none? && block.nil?
      AttributesAndTokenLists::TagBuilder.new(@view_context.tag, @tag_name, @attributes)
    else
      @view_context.tag.with_options(@attributes).public_send(@tag_name, *arguments, &block)
    end
  end

  def with(*names, **choices, &block)
    sliced = variants_at(*names) + choices.filter_map { |name, variant| @variants.dig(name, variant) }

    sliced.reduce(self, :merge).then { block.nil? ? _1 : _1.yield_self(&block) }
  end

  def dup
    AttributesAndTokenLists::ViewContext.new(
      @view_context,
      @tag_name,
      variants: @variants,
      default_variants: @default_variants,
      **@attributes.dup
    )
  end

  def method_missing(name, ...)
    receiver =
      if (variant = find_variant_by_name!(name))
        define_singleton_method(name) do
          merge(variant).tap do |builder|
            if variant.is_a?(AttributesAndTokenLists::ViewContext)
              builder.instance_variable_set(:@tag_name, variant.instance_variable_get(:@tag_name))
            end
          end
        end

        self
      elsif @view_context.respond_to?(name)
        @view_context.with_options(@attributes)
      else
        super
      end

    receiver.public_send(name, ...)
  end

  def respond_to_missing?(name, include_private = false)
    @view_context.respond_to?(name, include_private)
  end

  private

  def variant_values
    @variants.each_value.to_a
  end

  def variants_at(*names)
    names.flatten.compact.map { |name| find_variant_by_name!(name) }
  end

  def find_variant_by_name!(name)
    if (variants = select_variants_by_name(name))
      if variants.many?
        raise VariantCollisionError, "#{name.inspect} matches several variants"
      else
        variants.first[name]
      end
    end
  end

  def select_variants_by_name(name)
    variant_values.filter { |variant| variant.key?(name) }.presence
  end

  def raise_collision!(key)
    raise VariantCollisionError, "Cannot define #{key.inspect}, it collides with a method name"
  end
end
