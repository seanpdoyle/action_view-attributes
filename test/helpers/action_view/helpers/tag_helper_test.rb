require "test_helper"

class ActionView::Helpers::TagHelperTest < ActionView::TestCase
  test "token_list and class_names helper" do
    [:token_list, :class_names].each do |helper_method|
      helper = ->(*arguments) { public_send(helper_method, *arguments) }

      assert_equal "song play", helper.(["song", { "play": true }]).to_s
      assert_equal "song", helper.({ "song": true, "play": false }).to_s
      assert_equal "song", helper.([{ "song": true }, { "play": false }]).to_s
      assert_equal "song", helper.({ song: true, play: false }).to_s
      assert_equal "song", helper.([{ song: true }, nil, false]).to_s
      assert_equal "song", helper.(["song", { foo: false }]).to_s
      assert_equal "song play", helper.({ "song": true, "play": true }).to_s
      assert_equal "", helper.({ "song": false, "play": false }).to_s
      assert_equal "123", helper.(nil, "", false, 123, { "song": false, "play": false }).to_s
      assert_equal "song", helper.("song", "song").to_s
      assert_equal "song", helper.("song song").to_s
      assert_equal "song", helper.("song\nsong").to_s
    end
  end

  test "token_list de-duplicates tokens" do
    tokens = token_list("one two", [ "three" ], "three", { four: true })

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
    attributes = { id: 1, **tag.attributes(class: class_names("one")) }

    assert_equal({ id: 1, class: class_names("one") }, attributes)
  end

  test "tag.attributes merges like a Hash of attributes" do
    attributes = tag.attributes(id: 1, class: "one").merge(hidden: true)

    assert_equal %(id="1" class="one" hidden="hidden"), attributes.to_s
  end

  test "tag.attributes combines TokenList attributes" do
    attributes = tag.attributes(class: class_names("one")).merge(class: class_names("one two"))

    assert_equal %(class="one two"), attributes.to_s
  end

  test "tag.attributes deeply merges Hash attributes" do
    assert_equal %(data-controller="one two"), tag.attributes(data: { controller: token_list("one") }).merge(data: { controller: "two" }).to_s
    assert_equal %(data-controller="one two"), tag.attributes(data: { controller: "one" }).merge(data: { controller: token_list("two") }).to_s
  end

  test "tag.attributes reverse merges Attributes" do
    one = tag.attributes(class: "one")
    two = tag.attributes(class: class_names("two"))

    assert_equal %(class="one two"), (one + two).to_s
  end

  test "tag.attributes deeply merges TokenList attributes" do
    attributes = tag.attributes(data: { controller: token_list("one") }).merge(data: { controller: token_list("two") })

    assert_equal %(data-controller="one two"), attributes.to_s
  end

  test "tag.attributes automatically wraps class values as TokenList instances" do
    attributes = tag.attributes class: ["one two", { three: false }, { four: true }]

    tokens = attributes[:class]

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two four ], tokens.to_a
  end

  test "tag.attributes automatically wraps aria: { labelledby: ... } values as TokenList instances" do
    attributes = tag.attributes aria: { labelledby: "one two" }

    tokens = attributes.dig(:aria, :labelledby)

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two ], tokens.to_a
  end

  test "tag.attributes automatically wraps aria-labelledby  values as TokenList instances" do
    attributes = tag.attributes "aria-labelledby": "one two"

    tokens = attributes["aria-labelledby".to_sym]

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two ], tokens.to_a
  end

  test "tag.attributes automatically wraps aria: { describedby: ... } values as TokenList instances" do
    attributes = tag.attributes aria: { describedby: "one two" }

    tokens = attributes.dig(:aria, :describedby)

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two ], tokens.to_a
  end

  test "tag.attributes automatically wraps aria-describedby values as TokenList instances" do
    attributes = tag.attributes "aria-describedby": "one two"

    tokens = attributes["aria-describedby".to_sym]

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two ], tokens.to_a
  end

  test "tag.attributes automatically wraps data: { action: ... } values as TokenList instances" do
    attributes = tag.attributes data: { action: "one two" }

    tokens = attributes.dig(:data, :action)

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two ], tokens.to_a
  end

  test "tag.attributes automatically wraps data-action values as TokenList instances" do
    attributes = tag.attributes "data-action": "one two"

    tokens = attributes["data-action".to_sym]

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two ], tokens.to_a
  end

  test "tag.attributes automatically wraps data: { controller: ... } values as TokenList instances" do
    attributes = tag.attributes data: { controller: "one two" }

    tokens = attributes.dig(:data, :controller)

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two ], tokens.to_a
  end

  test "tag.attributes automatically wraps data-controller values as TokenList instances" do
    attributes = tag.attributes "data-controller": "one two"

    tokens = attributes["data-controller".to_sym]

    assert_kind_of ActionView::AttributesAndTokenLists::TokenList, tokens
    assert_equal %w[ one two ], tokens.to_a
  end

  test "with_attributes can have options decorated onto it" do
    with_attributes class: "one two" do |styled|
      assert_equal %{<a class="one two" href="/">styled</a>}, styled.link_to("styled", "/")
      assert_equal %{<a class="one two three" href="/">styled</a>}, styled.link_to("styled", "/", class: "three")
    end
  end

  test "with_attributes accepts another Attributes instance to have options decorated onto" do
    base = with_attributes class: "one two"
    styled = with_attributes base, class: "three"

    assert_equal %{<a class="one two" href="/">styled</a>}, base.link_to("styled", "/")
    assert_equal %{<a class="one two three" href="/">styled</a>}, styled.link_to("styled", "/")
    assert_equal %{<a class="one two three four" href="/">styled</a>}, styled.link_to("styled", "/", class: "four")
  end

  test "with_attributes accepts a context to have options decorated onto" do
    styled = with_attributes tag, class: "one"

    assert_equal(%{<a class="one" href="/">styled</a>}, styled.a(href: "/") { "styled" })
    assert_equal(%{<a class="one two" href="/">styled</a>}, styled.a(class: "two", href: "/") { "styled" })
  end
end
