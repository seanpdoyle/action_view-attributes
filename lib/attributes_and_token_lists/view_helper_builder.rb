class AttributesAndTokenLists::ViewHelperBuilder
  def self.base(name, tag_name: self.tag_name, **defaults, &block)
    if block.present?
      builder_class = Class.new(self) do
        self.tag_name = tag_name

        block.arity.zero? ? instance_exec(&block) : yield_self(&block)
      end

      if name.in?(instance_methods) && (existing_method = instance_method(name))
        raise <<~ERROR
            Cannot define "#{existing_method.name}", it's already defined by #{existing_method.source_location}"
        ERROR
      else
        define_method name do
          builder_class.new(view_context, defaults, tag_name: tag_name)
        end
      end
    else
      variant(name, tag_name: tag_name, **defaults)
    end
  end

  def self.builder(...)
    base(...)
  end

  def self.variant(name, tag_name: self.tag_name, **defaults)
    if name.in?(instance_methods) && (existing_method = instance_method(name))
      raise <<~ERROR
          Cannot define "#{existing_method.name}", it's already defined by #{existing_method.source_location}"
      ERROR
    else
      define_method name do |*arguments, **options, &block|
        tag_builder = as(tag_name).merge!(defaults)

        if arguments.none? && options.none? && block.nil?
          tag_builder
        else
          tag_builder.tag(*arguments, **options, &block)
        end
      end
    end
  end
end
