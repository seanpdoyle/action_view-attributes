class AttributesAndTokenLists::Configuration
  def initialize(name, &block)
    @name = name
    @variants = Hash.new { {} }

    if block
      block.arity.zero? ? instance_exec(&block) : yield_self(&block)
    end
  end

  def lookup(*names, **variants, &block)
    anonymous = @variants[:_anonymous].slice(*names)
    named = @variants.except(:_anonymous).values.map { _1.values_at(*names) }
    qualified = @variants.except(:_anonymous).values_at(*variants.keys).map { _1.values_at(*variants.values) }

    [anonymous, *named, *qualified].flatten!.tap(&:compact_blank!)
  end

  def configure(builder, &block)
    @variants[:_anonymous].each do |name, variants|
      define_variants_on(builder, name, variants, &block)
    end

    @variants.except(:_anonymous).each do |key, options|
      options.each do |name, variants|
        define_variants_on(builder, name, variants, &block)
      end
    end
  end

  ruby2_keywords def variant(name, *attributes)
    @variants.deep_merge!(_anonymous: { name => attributes })
  end

  def variants(**values)
    @variants.deep_merge!(values)
  end

  private

  def define_variants_on(builder, name, *variants, &block)
    attributes = variants.tap(&:flatten!).yield_self(&block)

    builder.define_singleton_method(name) { attributes.dup }
  end
end
