require "test_helper"

class AttributesAndTokenLists::ApplicationHelperTest < ActionView::TestCase
  include AttributesAndTokenLists::ApplicationHelper

  test "token_list and class_names helper" do
    [:token_list, :class_names].each do |helper_method|
      helper = ->(*arguments) { public_send(helper_method, *arguments) }

      assert_equal "song play", helper.call(["song", {play: true}]).to_s
      assert_equal "song", helper.call({song: true, play: false}).to_s
      assert_equal "song", helper.call([{song: true}, {play: false}]).to_s
      assert_equal "song", helper.call({song: true, play: false}).to_s
      assert_equal "song", helper.call([{song: true}, nil, false]).to_s
      assert_equal "song", helper.call(["song", {foo: false}]).to_s
      assert_equal "song play", helper.call({song: true, play: true}).to_s
      assert_equal "", helper.call({song: false, play: false}).to_s
      assert_equal "123", helper.call(nil, "", false, 123, {song: false, play: false}).to_s
      assert_equal "song", helper.call("song", "song").to_s
      assert_equal "song", helper.call("song song").to_s
      assert_equal "song", helper.call("song\nsong").to_s
    end
  end

  test "token_list de-duplicates tokens" do
    tokens = token_list("one two", ["three"], "three", {four: true})

    assert_equal "one two three four", tokens.to_s
  end

  test "token_list accepts TokenList instances" do
    tokens = token_list("one two", token_list("three"))

    assert_equal "one two three", tokens.to_s
  end

  test "token_list merges TokenList instances" do
    tokens = token_list("one two").merge(token_list("three"))

    assert_equal "one two three", tokens.to_s
  end

  test "token_list without arguments returns a blank list" do
    tokens = token_list

    assert_empty tokens.to_a
  end

  test "tag.attributes without arguments returns blank Attributes" do
    attributes = tag.attributes

    assert_empty attributes.to_h
  end

  test "tag.attributes merges into TokenList attributes" do
    attributes = tag.attributes(class: class_names("one")).merge(class: "one two")

    assert_equal %(class="one two"), attributes.to_s
  end

  test "tag.attributes can be splatted" do
    attributes = {id: 1, **tag.attributes(class: class_names("one"))}

    assert_equal({:id => 1, "class" => class_names("one")}, attributes)
  end

  test "tag.attributes merges like a Hash of attributes" do
    attributes = tag.attributes(id: 1, class: "one").merge(hidden: true)

    assert_equal %(id="1" class="one" hidden="hidden"), attributes.to_s
  end

  test "tag.attributes merges variable arguments" do
    attributes = tag.attributes({id: 1, class: "one"}, {hidden: true})

    assert_equal %(id="1" class="one" hidden="hidden"), attributes.to_s
  end

  test "tag.attributes merges variable arguments, with a final override" do
    left = tag.attributes(id: 1)
    right = tag.attributes(class: "one")

    attributes = tag.attributes(left, right, class: "two")

    assert_equal %(id="1" class="one two"), attributes.to_s
  end

  test "tag.attributes combines TokenList attributes" do
    attributes = tag.attributes(class: class_names("one")).merge(class: class_names("one two"))

    assert_equal %(class="one two"), attributes.to_s
  end

  test "tag.attributes.aria deeply merges" do
    assert_equal %(aria-describedby="one two three"), tag.attributes(aria: {describedby: token_list("one")}).aria(describedby: "two").aria(describedby: "three").to_s
    assert_equal %(aria-describedby="one two three"), tag.attributes(aria: {describedby: "one"}).aria(describedby: token_list("two")).aria(describedby: "three").to_s
  end

  test "tag.attributes.data deeply merges" do
    assert_equal %(data-controller="one two three"), tag.attributes(data: {controller: token_list("one")}).data(controller: "two").data(controller: "three").to_s
    assert_equal %(data-controller="one two three"), tag.attributes(data: {controller: "one"}).data(controller: token_list("two")).data(controller: "three").to_s
  end

  test "tag.attributes deeply merges Hash attributes" do
    assert_equal %(data-controller="one two"), tag.attributes(data: {controller: token_list("one")}).merge(data: {controller: "two"}).to_s
    assert_equal %(data-controller="one two"), tag.attributes(data: {controller: "one"}).merge(data: {controller: token_list("two")}).to_s
  end

  test "tag.attributes merges with indifferent access" do
    assert_equal %(data-controller="one two"), tag.attributes("data-controller" => "one").merge("data-controller": "two").to_s
  end

  test "tag.attributes reverse merges Attributes" do
    one = tag.attributes(class: "one")
    two = tag.attributes(class: class_names("two"))

    assert_equal %(class="one two"), (one + two).to_s
  end

  test "tag.attributes deeply merges TokenList attributes" do
    attributes = tag.attributes(data: {controller: token_list("one")}).merge(data: {controller: token_list("two")})

    assert_equal %(data-controller="one two"), attributes.to_s
  end

  test "tag.attributes automatically wraps class values as TokenList instances" do
    attributes = tag.attributes class: ["one two", {three: false}, {four: true}]

    tokens = attributes[:class]

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two four], tokens.to_a
  end

  test "tag.attributes automatically wraps aria: { labelledby: ... } values as TokenList instances" do
    attributes = tag.attributes aria: {labelledby: "one two"}

    tokens = attributes.dig(:aria, :labelledby)

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two], tokens.to_a
  end

  test "tag.attributes automatically wraps aria-labelledby  values as TokenList instances" do
    attributes = tag.attributes "aria-labelledby": "one two"

    tokens = attributes[:"aria-labelledby"]

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two], tokens.to_a
  end

  test "tag.attributes automatically wraps aria: { describedby: ... } values as TokenList instances" do
    attributes = tag.attributes aria: {describedby: "one two"}

    tokens = attributes.dig(:aria, :describedby)

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two], tokens.to_a
  end

  test "tag.attributes automatically wraps aria-describedby values as TokenList instances" do
    attributes = tag.attributes "aria-describedby": "one two"

    tokens = attributes[:"aria-describedby"]

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two], tokens.to_a
  end

  test "tag.attributes automatically wraps data: { action: ... } values as TokenList instances" do
    attributes = tag.attributes data: {action: "one two"}

    tokens = attributes.dig(:data, :action)

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two], tokens.to_a
  end

  test "tag.attributes automatically wraps data-action values as TokenList instances" do
    attributes = tag.attributes "data-action": "one two"

    tokens = attributes[:"data-action"]

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two], tokens.to_a
  end

  test "tag.attributes automatically wraps data: { controller: ... } values as TokenList instances" do
    attributes = tag.attributes data: {controller: "one two"}

    tokens = attributes.dig(:data, :controller)

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two], tokens.to_a
  end

  test "tag.attributes automatically wraps data-controller values as TokenList instances" do
    attributes = tag.attributes "data-controller": "one two"

    tokens = attributes[:"data-controller"]

    assert_kind_of AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[one two], tokens.to_a
  end

  test "tag.attributes are serialized by the tag helper" do
    attributes = tag.attributes data: {controller: "one two"}

    assert_equal %(<form data-controller="one two"></form>), tag.form(attributes)
  end

  test "tag.attributes are serialized by the tag helper when merged" do
    attributes = tag.attributes(class: "one").merge(class: "two")

    assert_equal %(<form class="one two"></form>), tag.form(attributes)
  end

  test "tag.attributes are serialized by the tag helper when deep merged" do
    attributes = tag.attributes(data: {controller: "one two"}).merge(data: {controller: "three"})

    assert_equal %(<form data-controller="one two three"></form>), tag.form(attributes)
  end

  test "tag.attributes instances can chain #tag calls" do
    attributes = tag.attributes(data: {controller: "one two"}).merge(data: {controller: "three"})

    assert_equal %(<form data-controller="one two three"></form>), attributes.tag.form
  end

  test "with_attributes can have options decorated onto it" do
    with_attributes class: "one two" do |styled|
      assert_equal %(<a class="one two" href="/">styled</a>), styled.link_to("styled", "/")
      assert_equal %(<a class="one two three" href="/">styled</a>), styled.link_to("styled", "/", class: "three")
    end
  end

  test "with_attributes accepts an Attributes instance" do
    base = tag.attributes class: "one"
    styled = with_attributes base

    assert_equal %(<span class="one">test</span>), styled.content_tag(:span, "test")
  end

  test "with_attributes can chain with_attributes calls decorate options further" do
    base = with_attributes class: "one two"
    styled = base.with_attributes class: "three"

    assert_equal %(<a class="one two" href="/">styled</a>), base.link_to("styled", "/")
    assert_equal %(<a class="one two three" href="/">styled</a>), styled.link_to("styled", "/")
    assert_equal %(<a class="one two three four" href="/">styled</a>), styled.link_to("styled", "/", class: "four")
  end

  test "tag.attributes.with_attributes merges with indifferent access" do
    base = with_attributes "class" => "one two"
    styled = base.with_attributes class: "three"

    assert_equal %(<a class="one two" href="/">styled</a>), base.link_to("styled", "/")
    assert_equal %(<a class="one two three" href="/">styled</a>), base.link_to("styled", "/", class: "three")
    assert_equal %(<a class="one two three" href="/">styled</a>), styled.link_to("styled", "/")
  end

  test "with_attributes can be chained off an Attributes instance" do
    attributes = tag.attributes class: "one"

    assert_equal %(<span class="one two">test</span>), attributes.with_attributes(class: "two").tag.span("test")
    assert_equal %(<span class="one two">test</span>), attributes.with_attributes("class" => "two").tag.span("test")
    assert_equal %(<span class="one two three">test</span>), attributes.with_attributes("class" => "two").tag.span("test", "class" => "three")
  end

  test "with_attributes chained off an Attributes instance accepts an Attributes instance" do
    base = tag.attributes class: "one"
    attributes = tag.attributes class: "two"
    styled = base.with_attributes attributes

    assert_equal %(<span class="one two">test</span>), styled.content_tag(:span, "test")
  end

  test "with_attributes chained off an Attributes instance accepts instances returned from with_attributes" do
    base = with_attributes class: "one"
    styled = base.with_attributes with_attributes class: "two"

    assert_equal %(<span class="one two">test</span>), styled.content_tag(:span, "test")
  end

  test "with_attributes can be chained off a TagBuilder instance with indifferent access" do
    styled = tag.with_attributes class: "one"

    assert_equal(%(<a class="one" href="/">styled</a>), styled.a(href: "/") { "styled" })
    assert_equal(%(<a class="one two" href="/">styled</a>), styled.a("class" => "two", :href => "/") { "styled" })
  end

  test "with_attributes chained off a TagBuilder instance accept Attributes instances" do
    styled = with_attributes class: "one two"

    assert_equal %(<a class="one two" href="/">styled</a>), tag.with_attributes(styled).a("styled", href: "/")
  end

  test "with_attributes does not require arguments" do
    assert_equal %(<div></div>), with_attributes.tag.div
    assert_equal %(<div></div>), tag.attributes.with_attributes.tag.div
  end

  test "with_attributes accepts an empty Hash" do
    assert_equal %(<div></div>), with_attributes({}).tag.div
    assert_equal %(<div></div>), with_attributes(**{}).tag.div
    assert_equal %(<div></div>), tag.attributes.with_attributes({}).tag.div
    assert_equal %(<div></div>), tag.attributes.with_attributes(**{}).tag.div
  end

  test "tag without arguments on an AttributeMerger instance continues the chain" do
    styled = with_attributes class: "one"

    assert_equal %(<span class="one">test</span>), styled.tag.span("test")
    assert_equal %(<span class="one">test</span>), tag.span("test", **styled)
    assert_equal %(<span class="one">test</span>), tag.span(styled) { "test" }
  end

  test "tag with arguments on an AttributeMerger instance invokes the method" do
    styled = with_attributes class: "one"

    assert_equal %(<br class="one" />), styled.tag(:br)
  end

  test "tag without arguments on an Attributes instance continues the chain" do
    styled = tag.attributes class: "one"

    assert_equal %(<span class="one">test</span>), styled.tag.span("test")
    assert_equal %(<span class="one">test</span>), tag.span("test", **styled)
    assert_equal %(<span class="one">test</span>), tag.span(styled) { "test" }
  end

  test "tag with arguments on an Attributes instance invokes the method" do
    styled = tag.attributes class: "one"

    assert_equal %(<br class="one">), styled.tag.br
    assert_equal %(<br class="one">), tag.br(styled)
  end
end
