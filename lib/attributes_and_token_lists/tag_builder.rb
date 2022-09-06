module AttributesAndTokenLists
  class TagBuilder
    attr_reader :tag_name

    def initialize(view_context, tag, tag_name, attributes = [])
      @view_context = view_context
      @tag = tag
      @tag_name = tag_name
      @attributes = attributes.reduce(Attributes.new(view_context, tag), :merge)
    end

    # Transforms a Hash into HTML Attributes, ready to be interpolated into
    # ERB.
    #
    #   <input <%= tag.attributes(type: :text, aria: { label: "Search" }) %> >
    #   # => <input type="text" aria-label="Search">
    def attributes(*options, **overrides)
      [*options, overrides].reduce(@attributes, :merge)
    end

    def with_attributes(*hashes, **overrides, &block)
      AttributeMerger.new(@view_context, self, [*hashes, overrides]).with_attributes(&block)
    end

    def to_s
      @tag.public_send(@tag_name, **attributes)
    end

    def method_missing(name, content = nil, *arguments, escape: true, **options, &block)
      case content
      when Hash, Attributes, AttributeMerger
        arguments = [content, *arguments]
        content = nil
      else
        content = @view_context.capture(self, &block) if block
      end

      @tag.public_send(name, content, escape: escape, **attributes(*arguments, **options), &block)
    end

    def respond_to_missing?(name, include_private = false)
      @tag.respond_to_missing?(name, include_private)
    end
  end
end
