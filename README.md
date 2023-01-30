# AttributesAndTokenLists

Transform `Hash` arguments into composable groups of HTML attributes

---

## Usage

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
