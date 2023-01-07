module AttributesAndTokenLists
  class AttributesBuilder
    class_attribute :tag_name, default: :div

    def self.base(name, tag_name: self.tag_name, **defaults, &block)
      if block.present?
        builder_class = Class.new(self) do
          self.tag_name = tag_name

          block.arity.zero? ? instance_exec(&block) : yield_self(&block)
        end

        define_method name do |*variants|
          base = builder_class.new(@view_context, **defaults)

          values = variants.compact.map { |variant| base.public_send(variant) }

          builder_class.new(@view_context, **values.reduce(base, :merge))
        end
      else
        variant(name, tag_name: tag_name, **defaults)
      end
    end

    def self.variant(name, tag_name: self.tag_name, **defaults)
      define_method name do
        @attributes.merge(defaults).as(tag_name)
      end
    end

    def initialize(view_context, **attributes)
      @view_context = view_context
      @attributes = view_context.tag.attributes(attributes)
    end

    def tag(...)
      @attributes.as(tag_name).tag(...)
    end

    def merge(...)
      AttributesBuilder.new(@view_context, **@attributes.merge(...))
    end

    def to_hash
      @attributes.to_hash
    end

    def to_h
      @attributes.to_h
    end

    def method_missing(name, *arguments, **options, &block)
      if @view_context.respond_to?(name)
        @view_context.public_send(name, *arguments, **@attributes.merge(options), &block)
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @view_context.respond_to?(name)
    end
  end
end
