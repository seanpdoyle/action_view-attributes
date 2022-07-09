# AttributesAndTokenLists

---

Change Action View's `token_lists` and `class_names` helpers to return instances
of `TokenList`, and `tag.attributes` helpers to return instances of
`Attributes`.

## Usage

Change `token_lists` and `class_names` to return instances of `TokenList`, and
`tag.attributes` helpers to return instances of `Attributes`. These objects know
how to serialize themselves into HTML views through their `#to_s` methods.
`TokenList` instances how to merge themselves with other `TokenList` and
`Enumerable` instances, and `Attributes` know how to merge themselves with other
`Hash` and `Attributes` instances, and know how to splat themselves out like a
`Hash`.

```ruby
def button
  tag.attributes class: "py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2"
end

def primary_button
  button.with_attributes class: "bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75"
end

primary_button.button_tag "Save", class: "uppercase"
#=> "<button class="py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2 bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75 uppercase">Save</button>

primary_button.link_to "Cancel", "/", class: "uppercase"
#=> "<a href="/" class="py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2 bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75 uppercase">Cancel</a>

primary_button.content_tag :a, "Cancel", href: "/", class: "uppercase"
#=> "<a href="/" class="py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2 bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75 uppercase">Cancel</a>

primary_button_builder = tag.with_attributes(primary_button)
primary_button_builder.a "Cancel", href: "/", class: "uppercase"
#=> "<a href="/" class="py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2 bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75 uppercase">Cancel</a>
```

### Summary

Expand `token_list` and `tag.attributes` helpers to construct `Attributes` and
`TokenList` instances that are smart about merging with other values turning
themselves into HTML.

Additionally, introduce the `with_attributes` view helper. Inspired by
`Object#with_options`, when the `with_attributes` helper is called with a block,
it yields a block argument that merges options into a base set of attributes.
For example:

```ruby
with_attributes class: "border rounded-sm p-4" do |styled|
  styled.link_to "I'm styled!", "/"
  # #=> <a class="border rounded-sm p-4" href="/">I'm styled!</a>
end
```

When the block is omitted, the object that would be the block parameter is
returned:

```ruby
styled = with_attributes class: "border rounded-sm p-4"
styled.link_to "I'm styled!", "/"
# #=> <a class="border rounded-sm p-4" href="/">I'm styled!</a>
```

To change the receiver from the view context, pass an object as the first
argument:

```ruby
button = with_attributes class: "border rounded-sm p-4"
button.link_to "I have a border", "/"
# #=> <a class="border rounded-sm p-4" href="/">I have a border</a>

primary = with_attributes button, class: "text-red-500 border-red-500"
primary.link_to "I have a red border", "/"
# #=> <a class="border rounded-sm p-4 text-red-500 border-red-500" href="/">I have a red border</a>

secondary = with_attributes button, class: "text-blue-500 border-blue-500"
secondary.link_to "I have a blue border", "/"
# #=> <a class="border rounded-sm p-4 text-blue-500 border-blue-500" href="/">I have a blue border</a>
```

For example, consider the following helpers:

```ruby
module ApplicationHelper
  def feed_section
    class_names "max-w-prose max-w-sm w-full lg:w-1/3"
  end

  def button
    tag.attributes class: "py-2 px-4 font-semibold shadow-md focus:outline-none focus:ring-2"
  end

  def primary
    button.with_attributes class: "bg-black rounded-lg text-white hover:bg-yellow-300 focus:ring-yellow-300 focus:ring-opacity-75"
  end

  def pagination_controller
    tag.attributes data: { controller: "pagination", action: "turbo:before-cache@document->pagination#preserveScroll turbo:before-render@document->pagination#injectIntoVisit" }
  end

  def sorted_controller
    tag.attributes data: { controller: "sorted", sorted_attribute_name_value: "data-code" }
  end
end
```

Using those helpers (or some other means of declaring re-usable `class_names`,
`token_list`, `with_attributes`, or `tag.attributes` calls), consider the
following diffs:

```diff
 <% if page.before_last? %>
   <div class="hidden last-of-type:flex justify-center my-6">
-    <%= link_to url_for(page: page.next_param, q: params[:q]), rel: "next", class: "py-2 px-4 bg-black text-white font-semibold rounded-lg shadow-md hover:bg-yellow-300 focus:outline-none focus:ring-2 focus:ring-yellow-300 focus:ring-opacity-75" do %>
+    <%= primary.link_to url_for(page: page.next_param, q: params[:q]), rel: "next" do %>
       Load more
     <% end %>
   </div>
 <% end %>

 <%= form_with url: sessions_path do |form| %>
-  <%= form.button class: "colspan-2 py-2 px-4 bg-black text-white font-semibold rounded-lg shadow-md hover:bg-yellow-300 focus:outline-none focus:ring-2 focus:ring-yellow-300 focus:ring-opacity-75" do %>
+  <%= form.button primary.merge(class: "colspan-2") do %>
     Sign in
   <% end %>
 <% end %>

-<section id="entries" class="max-w-prose max-w-sm w-full lg:w-1/3 font-medium" data-controller="pagination sorted" data-sorted-attribute-name-value="data-code" data-action="turbo:before-cache@document->pagination#preserveScroll turbo:before-render@document->pagination#injectNextPageIntoBody">
+<section id="entries" class="<%= feed_section | "font-medium" %>" <%= pagination_controller | sorted_controller %>>
   <%= render partial: "entries/page", object: @page %>
 </section>
```

### Other Information

If we're interested in supporting this, there is some other related work:

* If there are scenarios where a view wants to opt-out of the values that have been iteratively built up to that point, it might be useful to declare `class_names!`, `token_list!`, and `tag.attributes!` variants to construct instances that don't merge and instead reset the values passed:
```ruby
class_names("font-semibold") | class_names!("font-bold") #=> "font-bold"
```
* If an application's shared `class_names` and `tag.attributes` calls are declared in a Helper module (like `ApplicationHelper`), changes to them wouldn't be visible to Action View's fragment caching calculations. This is a problem if their call sites don't include a fragment cache busting comment. **Is there currently other work in-flight to incorporate Helper module source code into cache key generation the way that view partial source code is incorporated?**
* We could potentially push this even further and implement [`TagHelper.build_tag_values`](https://github.com/rails/rails/blob/90d0b42bd8206e942597b64163837287caf7119d/actionview/lib/action_view/helpers/tag_helper.rb#L377-L395) and [`TagBuilder#tag_options`](https://github.com/rails/rails/blob/90d0b42bd8206e942597b64163837287caf7119d/actionview/lib/action_view/helpers/tag_helper.rb#L82-L122), [`TagBuilder#boolean_tag_option`](https://github.com/rails/rails/blob/90d0b42bd8206e942597b64163837287caf7119d/actionview/lib/action_view/helpers/tag_helper.rb#L124-L126), [`TagBuilder#tag_option`](https://github.com/rails/rails/blob/90d0b42bd8206e942597b64163837287caf7119d/actionview/lib/action_view/helpers/tag_helper.rb#L128-L140), [`TagBuilder#prefix_tag_option`](https://github.com/rails/rails/blob/90d0b42bd8206e942597b64163837287caf7119d/actionview/lib/action_view/helpers/tag_helper.rb#L143-L149), and the supporting [constant declarations](https://github.com/rails/rails/blob/90d0b42bd8206e942597b64163837287caf7119d/actionview/lib/action_view/helpers/tag_helper.rb#L18-L42) in terms of the new `Attributes` class, (perhaps in a file or namespace of its own).

**Tangent:** Even bigger picture
---

I'm curious if transitioning Action View's `tag` and `content_tag` helpers from String concatenation into an architecture that outsourced element and attribute construction to something like Nokogiri or Nokogumbo would reduce Action View's footprint. For example, if calls to helpers like `button_tag` or `form_with` returned Nokogiri `Node` instances that knew how to turn themselves into HTML, dealing with merging attribute and DOMTokenList values ([denoted as `kwattr_*` for "keyword attributes" in Nokogiri](https://nokogiri.org/rdoc/Nokogiri/XML/Node.html#kwattr_add-instance_method)) might be more straightforward to implement.

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
