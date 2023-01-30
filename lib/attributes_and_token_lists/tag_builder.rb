module AttributesAndTokenLists
  class TagBuilder
    class_attribute :tag_name, instance_accessor: false, default: :div

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

    def initialize(view_context, *values, tag_name: self.class.tag_name)
      self.view_context = view_context
      self.attributes = view_context.tag.attributes(*values)
      self.tag_name = tag_name
    end

    def merge!(...)
      tap { attributes.merge!(...) }
    end

    def merge(...)
      dup.merge!(...)
    end
    alias_method :call, :merge

    def with(*names)
      variants = names.tap(&:compact!).tap(&:flatten!).map { |name| public_send(name) }

      variants.reduce(dup) { |combined, variant| combined.merge!(variant.to_h) }
    end

    def as(tag_name)
      tap { self.tag_name = tag_name }
    end

    def tag(*arguments, **options, &block)
      tag_builder = view_context.tag.with_options(attributes)

      if arguments.none? && options.none? && block.nil?
        tag_builder
      else
        tag_builder.public_send(tag_name, *arguments, **options, &block)
      end
    end

    def to_s
      attributes.to_s
    end

    def dup
      self.class.new(view_context, attributes.dup, tag_name: tag_name)
    end

    def method_missing(name, ...)
      receiver =
        if attributes.respond_to?(name)
          attributes
        elsif view_context.respond_to?(name)
          view_context.with_options(attributes)
        else
          view_context.tag.with_options(attributes)
        end

      receiver.public_send(name, ...)
    end

    def respond_to_missing?(name, include_private = false)
      [attributes, view_context, view_context.tag].any? { |receiver| receiver.respond_to?(name, include_private) }
    end

    private

    attr_accessor :attributes, :tag_name, :view_context
  end
end
