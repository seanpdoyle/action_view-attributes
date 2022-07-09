module AttributesAndTokenLists
  module Backports
    # Transforms a Hash into HTML Attributes, ready to be interpolated into
    # ERB.
    #
    #   <input <%= tag.attributes(type: :text, aria: { label: "Search" }) %> >
    #   # => <input type="text" aria-label="Search">
    def attributes(attributes)
      tag_options(attributes.to_h).to_s.strip.html_safe
    end
  end
end
