# Changelog

The noteworthy changes for each AttributesAndTokenLists version are
included here. For a complete changelog, see the [commits] for each version via
the version links.

[commits]: https://github.com/seanpdoyle/attributes_and_token_lists

## main

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
