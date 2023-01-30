class ActionView::Helpers::TagHelper::TagBuilder
  # === Passing a single Hash argument
  #
  #   <input <%= tag.attributes(type: :text, aria: { label: "Search" }) %> >
  #   # => <input type="text" aria-label="Search">
  #
  # === Passing multiple Hash arguments
  #
  # Passing multiple Hash arguments will be deep merged from left to right into a single Hash:
  #
  #   <input <%= tag.attributes({ type: :text }, { id: "search" }, { aria: { label: "Search" } }) %> >
  #   # => <input type="text" id="search" aria-label="Search">
  #
  # Hash arguments can be mixed with keyword arguments:
  #
  #   <input <%= tag.attributes({ type: :text }, { id: "search" }, { aria: { label: "Search" } }, aria: { disabled: true }) %> >
  #   # => <input type="text" id="search" aria-label="Search" aria-disabled="true">
  #
  # When called outside of a rendering context, <tt>tag.attributes</tt>
  # will return a <tt>Hash</tt>-like object that knows how to render
  # itself to HTML:
  #
  #   primary = { class: "bg-red-500 text-white" }
  #   large = { class: "text-lg p-4" }
  #
  #   button_tag "Click me!", tag.attributes(primary, large)
  #   # => <button name="button" type="submit" class="bg-red-500 text-white text-lg p-4">Click me!</button>
  #
  #   tag.button "Click me!", id: "cta", **tag.attributes(primary, large)
  #   # => <button id="cta" class="bg-red-500 text-white text-lg p-4">Click me!</button>
  #
  # === Token list support
  #
  # Attribute merging will account for token lists attributes (like <tt>class</tt> and <tt>aria-labelledby</tt>) by combining values from left to right
  #
  #   <input <%= tag.attributes({ class: "font-bold" }, { class: ["text-sm", "text-gray-700"] }, class: "p-2") %> >
  #   # => <input class="font-bold text-sm text-gray-700 p-2" >
  #
  # To override token list merging for an attribute, pass its name with a `!` suffix:
  #
  #   attributes = tag.attributes({ class: "default" }, { class!: "first-override" }, class!: "second-override")
  #   attributes.to_h # => { class: "second-override" }
  #   attributes.to_s # => "class=\"second-override\""
  #
  # Keys that end with <tt>!</tt> are only temporary. Accessing
  # <tt>attributes[:class!]</tt> will return <tt>nil</tt> in the code sample
  # above.
  #
  # === Configuring token list support
  #
  # To treat addition attributes as token lists, add values to the <tt>config.action_view.token_lists</tt> value:
  #
  #   config.action_view.token_lists << "data-action"
  #   config.action_view.token_lists << "data-controller"
  #   config.action_view.token_lists << /data-(.*)-target/
  #
  ruby2_keywords def attributes(*hashes)
    attributes = ActionView::Attributes.new(@view_context) do |value|
      tag_options(value).to_s.strip.html_safe
    end

    hashes.tap(&:compact!).reduce(attributes, :merge!)
  end

  # Inspired by `Object#with_options`, when the `with_attributes` helper is
  # called with a block, it forwards the other arguments to
  # `ActionView::Helpers::TagHelper::TagBuilder#attributes`, then yields that
  # value to the block argument that merges options into a base set of
  # attributes. For example:
  #
  #   border = { class: "border rounded-sm p-4" }
  #   spacing = { class: "p-4" }
  #
  #   tag.with_attributes border, spacing do |styled|
  #     styled.button "I'm red!", class: "text-red-500"
  #     #=> <button class="border rounded-sm p-4 text-red-500">I'm red!</button>
  #   end
  #
  # When the block is omitted, the object that would be the block
  # parameter is returned:
  #
  #   border = { class: "border rounded-sm p-4" }
  #   spacing = { class: "p-4" }
  #
  #   styled = tag.with_attributes border, spacing
  #   styled.button "I'm styled!", class: "text-red-500"
  #     #=> <button class="border rounded-sm p-4 text-red-500">I'm red!</button>
  #
  # To change the receiver from the view context, invoke
  # <tt>with_attributes</tt> an the instance returned from another
  # <tt>with_attributes</tt> call:
  #
  #   button = tag.with_attributes class: "border rounded-sm p-4"
  #   button.a "I have a border", href: "/"
  #   #=> <a class="border rounded-sm p-4" href="/">I have a border</a>
  #
  #   primary = button.with_attributes class: "text-red-500 border-red-500"
  #   primary.a "I have a red border", href: "/"
  #   #=> <a class="border rounded-sm p-4 text-red-500 border-red-500" href="/">I have a red border</a>
  #
  #   secondary = button.with_attributes class: "text-blue-500 border-blue-500"
  #   secondary.a "I have a blue border", href: "/"
  #   #=> <a class="border rounded-sm p-4 text-blue-500 border-blue-500" href="/">I have a blue border</a>
  #
  ruby2_keywords def with_attributes(*values, &block)
    with_options(attributes(*values), &block)
  end
end
