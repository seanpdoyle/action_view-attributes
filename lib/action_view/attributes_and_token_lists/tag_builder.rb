module ActionView
  module AttributesAndTokenLists
    class TagBuilder
      def initialize(view_context, tag, attributes = [])
        @view_context = view_context
        @tag = tag
        @attributes = attributes
      end

      # Transforms a Hash into HTML Attributes, ready to be interpolated into
      # ERB.
      #
      #   <input <%= tag.attributes(type: :text, aria: { label: "Search" }) %> >
      #   # => <input type="text" aria-label="Search">
      def attributes(*options, **overrides)
        [*options, overrides].reduce(Attributes.new(@tag, @view_context), :merge)
      end

      def with_attributes(*attributes, **options)
        self.class.new(@view_context, @tag, [*@attributes, *attributes, options])
      end

      def method_missing(name, content = nil, *arguments, escape: true, **options, &block)
        case content
        when Hash, Attributes, AttributeMerger
          arguments = [content, *arguments]
          content = nil
        else
          content = @view_context.capture(self, &block) if block
        end

        @tag.public_send(name, content, escape: escape, **attributes(*@attributes, *arguments, **options), &block)
      end

      def respond_to_missing?(name, include_private = false)
        @tag.respond_to_missing?(name, include_private)
      end
    end
  end
end
