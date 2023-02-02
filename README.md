# AttributesAndTokenLists

Transform `Hash` arguments into composable groups of HTML attributes

---

## `ActionView::Attributes`

### `tag.attributes`

Installing `AttributesAndTokenLists` extends Action View's `tag.attributes` to
return an instance of `ActionView::Attributes`.

`ActionView::Attributes` are `Hash`-like objects with two distinguishing
abilities:

1. They know how to serialize themselves into valid HTML attributes:

    ```ruby
    attributes = tag.attributes class: "border rounded-full p-4 aria-[expanded=false]:text-gray-500",
                                aria: {
                                  controls: "a_disclosure",
                                  expanded: false
                                },
                                data: {
                                  controller: "disclosure",
                                  action: "click->disclosure#toggle",
                                  disclosure_element_outlet: "#a_disclosure"
                                }

    attributes.to_s
    # => class="border rounded-full p-4 aria-[expanded=false]:text-gray-500" aria-controls="a_disclosure" aria-expanded="false" data-controller="disclosure" data-action="click->disclosure#toggle" data-disclosure-element-outlet="#a_disclosure"
    ```

2. They know how to deeply merge into attributes that are token lists:

    ```ruby
    border = tag.attribute class: "border rounded-full"
    padding = tag.attribute class: "p-4"

    attributes = border.merge(padding).merge(class: "a-special-class")

    attributes.to_h
    # => { class: "border rounded-full p-4 a-special-class" }
    ```

### `with_options`

Since `ActionView::Attributes` instances are `Hash`-like, they're compatible
with [Object#with_options][]. Compose instances together to

[Object#with_options]: https://edgeapi.rubyonrails.org/classes/Object.html#method-i-with_options

```ruby
def focusable
  tag.attributes class: "focus:outline-none focus:ring-2"
end

def button
  tag.attributes class: "py-2 px-4 font-semibold shadow-md"
end

def primary
  tag.attributes class: "bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75"
end

def primary_button(...)
  tag.with_options([focusable, button, primary].reduce(:merge))
end

primary_button.button "Save", class: "uppercase"
#=> <button class="py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2 bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75 uppercase">
#=>   Save
#=> </button>

primary_button.a "Cancel", href: "/", class: "uppercase"
#=> <a href="/" class="py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2 bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75 uppercase">
#=>   Cancel
#=> </a>
```

Attribute support isn't limited to `class:`. Declare composable ARIA- and
Stimulus-aware attributes with `aria:` and `data:` keys:

```ruby
def disclosure(controls: nil, expanded: false)
  tag.attributes aria: {controls:, expanded:},
                 data: {controller: "disclosure", action: "click->disclosure#toggle", disclosure_element_outlet: ("#" + controls if controls)}
end

def primary_disclosure_button(controls: nil, expanded: false)
  tag.with_options([focusable, button, primary, disclosure(controls:, expanded:)].reduce(:merge))
end

primary_disclosure_button.button "Toggle", controls: "a_disclosure", expanded: true
#=> <button class="py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2 bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75"
#=>         aria-controls="a_disclosure" aria-expanded="true"
#=>         data-controller="disclosure" data-action="click->disclosure#toggle" data-disclosure-element-outlet="#a_disclosure">
#=>   Toggle
#=> </button>

primary_disclosure_button.summary "Toggle"
#=> <summary class="py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2 bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75"
#=>          data-controller="disclosure" data-action="click->disclosure#toggle">
#=>   Toggle
#=> </summary>
```

### `#with_attributes`

Inspired by `#with_options`, the `#with_attributes` is a short-hand method that
combines any number of `Hash`-like arguments into an `ActionView::Attributes`
instance, then passes that along as an argument to `#with_options`.

The `#with_attributes` method available both as an Action View helper method and
as `tag` instance method.

```ruby
with_attributes {class: "border rounded-full"}, {class: "p-4"}, class: "focus:outline-none focus:ring" do |styled|
  styled.link_to "A link", "/a-link"
  # => <a class="border rounded-full p-4 focus:outline-none focus:ring" href="/a-link">A link</a>

  styled.button_tag "A button", type: "button"
  # => <button class="border rounded-full p-4 focus:outline-none focus:ring" name="button" type="button">A button</button>
end

builder = tag.with_attributes {class: "border rounded-full"}, {class: "p-4"}, class: "focus:outline-none focus:ring"

builder.a "A link", href: "/a-link"
# => <a class="border rounded-full p-4 focus:outline-none focus:ring" href="/a-link">A link</a>

builder.button_tag "A button", type: "button"
# => <button class="border rounded-full p-4 focus:outline-none focus:ring" type="button">A button</button>
```

## Attribute Variants

Define your Attribute variations

```ruby
attribute_helpers :ui do |ui|
  focusable = "ring-current focus:outline-none focus:ring"

  ui.variant :link, class: ["ring-inset", focusable]

  ui.variant :label, class: "text-sm" do |label|
    label.variant :interactive, class: ["cursor-pointer peer-focus:ring", focusable]
  end

  ui.variant :input class: focusable do |input|
    placeholder = "placeholder:text-current placeholder:text-opacity-95 before:text-opacity-95"

    input.variant :type, {
      text: {class: [placeholder, "border-black/20 text-sm"]},
      textarea: {class: ["min-h-fit border-0 text-sm bg-white", placeholder]},
      select: {class: ["inline-flex items-center gap-4 font-medium leading-tight border-0 shadow-md p-4", placeholder]}
    }
  end

  ui.variant :button, class: [focusable, "inline-flex items-center justify-center disabled:cursor-none"] do |button|
    button.variants(
      style: {
        primary: {class: "bg-purple-900 text-white ring-purple-900 focus:ring-offset-2"},
        secondary: {class: "bg-purple-900/5 text-purple-900/95"},
        tertiary: {class: "bg-white text-purple-900 border border-current/20 hover:bg-opacity-20 aria-expanded:bg-opacity-30"}
      },
      size: {
        small: "text-sm p-1",
        medium: "text-md p-2"
        large: "text-lg p-4"
      }
    )
  end
end
```

From your view templates, pass them as arguments, or invoke view helper methods:

```ruby
ui.link.link_to "A page", "/page"
# => <a class="ring-inset ring-current focus:outline-none focus:ring" href="/page">A page</a>

ui.button.with(style: :primary, size: :large).button_tag "Click Me!", type: :button
# => <button type="button"
# =>         class="ring-current focus:outline-none focus:ring
# =>                inline-flex items-center justify-center disabled:cursor-none bg-purple-900 text-white ring-purple-900 focus:ring-offset-2 text-lg p-4">
# =>   Click Me!
# => </button>
```

If variant names are unique across keys, you can pass them directly to `#with`:

```ruby
ui.button.with(:primary, :large).button_tag "Click Me!", type: :button
# => <button type="button"
# =>         class="ring-current focus:outline-none focus:ring
# =>                inline-flex items-center justify-center disabled:cursor-none bg-purple-900 text-white ring-purple-900 focus:ring-offset-2 text-lg p-4">
# =>   Click Me!
# => </button>
```

You can mix-and-match variant arguments:

```ruby
ui.button.with(:primary, size: :large).link_to "Click Me!", "/"
# => <a href="/"
# =>    class="ring-current focus:outline-none focus:ring
# =>           inline-flex items-center justify-center disabled:cursor-none bg-purple-900 text-white ring-purple-900 focus:ring-offset-2 text-lg p-4">
# =>   Click Me!
# => </a>
```

When invoking a single variant, you can forego calls to `#with` and invoke the name of the variant directly:

```ruby
ui.button.primary.button_tag "Click Me!"
# => <button class="ring-current focus:outline-none focus:ring
# =>                inline-flex items-center justify-center disabled:cursor-none bg-purple-900 text-white ring-purple-900 focus:ring-offset-2">
# =>   Click Me!
# => </button>
```

Attribute Variants are `Hash`-like, and respond to `#[]`, `#merge`, `#to_h`, `#to_hash`, and can be double-splatted with `**`.

They're also valid `Object#with_options` arguments:

```ruby
form.with_options(ui.input.text).text_field :name
# => <input id="article_name" name="article[name]" type="text"
# =>       class="placeholder:text-current placeholder:text-opacity-95 before:text-opacity-95
# =>              ring-current focus:outline-none focus:ring
# =>              border-black/20 text-sm">
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'attributes_and_token_lists', github: "seanpdoyle/attributes_and_token_lists", branch: "main"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install attributes_and_token_lists
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
