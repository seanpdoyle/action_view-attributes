module AttributesAndTokenLists
  class AttributeMerger
    instance_methods.each do |method|
      undef_method(method) unless method.start_with?("__", "instance_eval", "class", "object_id")
    end

    def initialize(view_context, context, options)
      @view_context = view_context
      @context = context
      @attributes = @view_context.tag.attributes(*options)
    end

    def with_attributes(*hashes, **overrides, &block)
      attribute_merger = AttributeMerger.new(@view_context, @context, [@attributes, *hashes, overrides])

      if block.nil?
        attribute_merger
      else
        block.arity.zero? ? attribute_merger.instance_eval(&block) : block.call(attribute_merger)
      end
    end
    alias_method :with_options, :with_attributes

    def tag(name = nil, options = nil, open = false, escape = true)
      if name.nil? && options.nil?
        AttributeMerger.new(@view_context, @view_context.tag, [@attributes])
      else
        @view_context.tag(name, @attributes.merge(options.to_h))
      end
    end

    def to_hash
      @attributes.to_hash
    end

    def to_h
      @attributes.to_h
    end

    def inspect
      "#<%<class>s:0x%<addr>08x context=%<context>s>" %
        {class: self.class, addr: object_id * 2, context: @context.inspect}
    end

    private

    def method_missing(method, *arguments, &block)
      options = nil
      if arguments.size == 1 && arguments.first.is_a?(Proc)
        proc = arguments.shift
        arguments << ->(*args) { @attributes.merge(proc.call(*args)) }
      elsif arguments.last.respond_to?(:to_hash)
        options = @attributes.merge(arguments.pop)
      else
        options = @attributes
      end

      if options
        if __options_are_keyword_arguments?(method)
          @context.__send__(method, *arguments, **options, &block)
        else
          @context.__send__(method, *arguments, options, &block)
        end
      else
        @context.__send__(method, *arguments, &block)
      end
    end

    def respond_to_missing?(*arguments)
      @context.respond_to?(*arguments)
    end

    def __options_are_keyword_arguments?(method)
      default_value = ::RUBY_VERSION >= "2.7.0"

      if @context.respond_to?(method)
        parameters = @context.method(method).parameters
        option, block = parameters.last(2)

        option =
          if option.nil? || (option.present? && block.nil? && option.first == :block)
            []
          elsif block.present? && block.first == :keyrest
            block
          else
            option
          end

        option.first == :keyrest
      else
        default_value
      end
    rescue NoMethodError
      default_value
    end
  end
end
