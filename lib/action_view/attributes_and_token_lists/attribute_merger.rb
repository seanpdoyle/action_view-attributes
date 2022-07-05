module ActionView
  module AttributesAndTokenLists
    class AttributeMerger < ActiveSupport::OptionMerger
      def initialize(view_context, context, options)
        @view_context = view_context
        super context, @view_context.tag.attributes(options)
      end

      def with_attributes(options, &block)
        attribute_merger = AttributeMerger.new @view_context, @context, @options.merge(options)

        if block.nil?
          attribute_merger
        else
          block.arity.zero? ? attribute_merger.instance_eval(&block) : block.call(attribute_merger)
        end
      end

      def tag(name = nil, options = nil, open = false, escape = true)
        if name.nil? && options.nil?
          AttributeMerger.new(@view_context, @view_context.tag, @options)
        else
          @view_context.tag(name, @options.merge(options.to_h))
        end
      end

      def to_hash
        @options.to_hash
      end

      def to_h
        @options.to_h
      end

      def inspect
        "#<%<class>s:0x%<addr>08x context=%<context>s>" %
          {class: self.class, addr: object_id * 2, context: @context.inspect}
      end
    end
  end
end
