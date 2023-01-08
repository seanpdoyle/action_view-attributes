# Changelog

The noteworthy changes for each AttributesAndTokenLists version are
included here. For a complete changelog, see the [commits] for each version via
the version links.

[commits]: https://github.com/seanpdoyle/attributes_and_token_lists

## main

* Bug: support attribute overrides for unclosed elements (for example,
  `<input>`)

* Bug: gracefully resolve `nil` value when combining variants

* Rename builder domain-specific language to combine `builder`, `base`, and
  `variant`:

    ```ruby
    ActiveSupport.on_load :attributes_and_token_lists do
      builder :ui do
        base :button, tag_name: "button", class: "cursor-pointer" do
          variant :primary, class: "text-white bg-green-500"
        end
      end
    end

    # Elsewhere
    ui.button.primary.tag "A button"
    # => <button class="cursor-pointer text-white bg-green-500">A button</button>
    ```


* Alias `define` to `variant`, and add support for combining variants

    ```ruby
    ActiveSupport.on_load :attributes_and_token_lists do
      define :ui do
        define :button, tag_name: "button", class: "cursor-pointer" do
          variant :primary, class: "text-white bg-green-500"
          variant :rounded, class: "rounded-full"
        end
      end
    end

    # Elsewhere
    ui.button(:primary, :rounded).tag "A button"
    # => <button class="cursor-pointer text-white bg-green-500 rounded-full">A button</button>
    ```

* Move configuration out of `app/views/initializers` and into a more
  conventional `config/initializers` file.

* Pre-define clumps of attributes by calling `AttributesAndTokenLists.define` in
  a `config/initializers` file, or an
  `app/views/initializers/attributes_and_token_lists.html.erb` template

  ```erb
  <%# app/views/initializers/attributes_and_token_lists.html.erb %>
  <%
    AttributesAndTokenLists.define :atl do
      define :button, tag_name: :button, class: "text-white p-4 focus:outline-none focus:ring" do
        define :primary, class: "bg-green-500"
        define :secondary, class: "bg-blue-500"
        define :tertiary, class: "bg-black"
      end
    end
  %>

  <%# elsewhere %>

  <%= atl.tag.button "Unstyled" %>            <%# => <button>Unstyled</button> %>
  <%= atl.button.tag "Base" %>                <%# => <button class="text-white p-4 focus:outline-none focus:ring">Base</button> %>
  <%= atl.button.primary.tag "Primary" %>     <%# => <button class="text-white p-4 focus:outline-none focus:ring bg-green-500">Primary</button> %>
  <%= atl.button.secondary.tag "Secondary" %> <%# => <button class="text-white p-4 focus:outline-none focus:ring bg-blue-500">Secondary</button> %>
  <%= atl.button.tertiary.tag "Tertiary" %>   <%# => <button class="text-white p-4 focus:outline-none focus:ring bg-black">Tertiary</button> %>

  <%= atl.button.primary.tag.a "Primary", href: "#" %> <%# => <a class="text-white p-4 focus:outline-none focus:ring bg-green-500" href="#">Primary</a> %>
  <%= atl.button.primary.link_to "Primary", "#" %>     <%# => <a class="text-white p-4 focus:outline-none focus:ring bg-green-500" href="#">Primary</a> %>
  ```

* Remove support for `Attributes#+` and `Attributes#|` aliases for
  `Attributes#merge`

* Resolve `Attributes#merge` primitive value override bug

* Decorate public interfaces instead of monkey-patching private ones

* Introduce [standard](https://github.com/testdouble/standard) for style
  violation linting

* Enable chaining `#with_attributes` and `#tag` off of `Attributes` instances
  and instances of `AttributeMerger` returned by other `#with_attributes` calls

* Ensure that `Attributes` are compliant with Action View-provided `tag` helpers

* Add `Attributes#with_attributes` and `Attributes#with_options` alias to enable
  decorating and chaining

* Support chaining view helpers off `Attributes` instances

  ```ruby
  styled = tag.attributes(class: "my-link-class")

  styled.link_to("A link", "/")
  ```

* Deep symbolize `Attributes` keys when splatting or calling
  `Attributes#to_hash`
