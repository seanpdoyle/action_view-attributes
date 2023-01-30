require "test_helper"

class AttributesAndTokenLists::ApplicationHelperTest < ActionView::TestCase
  test "tag.attributes without arguments returns blank Attributes" do
    attributes = tag.attributes

    assert_empty attributes.to_h
  end

  test "tag.attributes with nil returns blank Attributes" do
    attributes = tag.attributes(nil)

    assert_empty attributes.to_h
  end

  test "tag.attributes merges into token list attributes" do
    attributes = tag.attributes(class: "one").merge(class: "one two")

    assert_equal %(class="one two"), attributes.to_s
  end

  test "tag.attributes can be splatted" do
    attributes = {id: 1, **tag.attributes(class: "one")}

    assert_equal({id: 1, class: "one"}, attributes)
  end

  test "tag.attributes merges like a Hash of attributes" do
    attributes = tag.attributes(id: 1, class: "one").merge(hidden: true)

    assert_equal %(id="1" class="one" hidden="hidden"), attributes.to_s
  end

  test "tag.attributes merges variable arguments" do
    attributes = tag.attributes({id: 1, class: "one"}, {hidden: true})

    assert_equal %(id="1" class="one" hidden="hidden"), attributes.to_s
  end

  test "tag.attributes merges variable arguments, with the last key-value pairs serving as overrides" do
    attributes = tag.attributes({type: nil}, {type: "button"}, type: "reset")

    assert_equal %(type="reset"), attributes.to_s
  end

  test "tag.attributes merges variable arguments, with a final override" do
    left = tag.attributes(id: 1)
    right = tag.attributes(class: "one")

    attributes = tag.attributes(left, right, class: "two")

    assert_equal %(id="1" class="one two"), attributes.to_s
  end

  test "tag.attributes combines token list attributes" do
    attributes = tag.attributes(class: "one").merge(class: "one two")

    assert_equal %(class="one two"), attributes.to_s
  end

  test "tag.attributes.aria deeply merges" do
    assert_equal %(aria-describedby="one two three"), tag.attributes(aria: {describedby: "one"}).aria(describedby: "two").aria(describedby: "three").to_s
  end

  test "tag.attributes.data deeply merges" do
    assert_equal %(data-controller="one two three"), tag.attributes(data: {controller: "one"}).data(controller: "two").data(controller: "three").to_s
  end

  test "tag.attributes deeply merges Hash attributes" do
    assert_equal %(data-controller="one two"), tag.attributes(data: {controller: "one"}).merge(data: {controller: "two"}).to_s
  end

  test "tag.attributes deeply merges token list attributes" do
    attributes = tag.attributes(data: {controller: "one"}).merge(data: {controller: "two"})

    assert_equal %(data-controller="one two"), attributes.to_s
  end

  test "tag.attributes are serialized by the tag helper" do
    attributes = tag.attributes data: {controller: "one two"}

    assert_equal %(<form data-controller="one two"></form>), tag.form(**attributes)
  end

  test "tag.attributes are serialized by the tag helper when merged" do
    attributes = tag.attributes(class: "one").merge(class: "two")

    assert_equal %(<form class="one two"></form>), tag.form(**attributes)
  end

  test "tag.attributes are serialized by the tag helper when deep merged" do
    attributes = tag.attributes(data: {controller: "one two"}).merge(data: {controller: "three"})

    assert_equal %(<form data-controller="one two three"></form>), tag.form(**attributes)
  end

  test "tag.attributes are compatible with tag.with_options calls" do
    attributes = tag.attributes(data: {controller: "one two"}).merge(data: {controller: "three"})

    assert_equal %(<form data-controller="one two three"></form>), tag.with_options(attributes).form
  end

  test "tag.attributes instances can chain view helper calls" do
    attributes = tag.attributes(class: "one two").merge(class: "three")

    assert_equal %(<a class="one two three" href="/">styled</a>), with_options(attributes).link_to("styled", "/")
  end

  test "tag.with_attributes delegates to tag.attributes, then passes to tag.with_options" do
    one = {data: {controller: "one"}}
    two = {data: {controller: "two"}}

    assert_equal %(<form data-controller="one two three"></form>), tag.with_attributes(one, two, data: {controller: "three"}).form
  end

  test "with_attributes can have options decorated onto it" do
    with_attributes class: "one two" do |styled|
      assert_equal %(<a class="one two" href="/">styled</a>), styled.link_to("styled", "/")
      assert_equal %(<a class="one two three" href="/">styled</a>), styled.link_to("styled", "/", class: "three")
    end
  end

  test "with_attributes accepts an Attributes instance" do
    base = tag.attributes class: "one"
    styled = with_attributes base, class: "two"

    assert_equal %(<span class="one two">test</span>), styled.content_tag(:span, "test")
  end

  test "with_attributes can chain with_attributes calls decorate options further" do
    base = with_attributes class: "one two"
    styled = base.with_attributes class: "three"

    assert_equal %(<a class="one two" href="/">styled</a>), base.link_to("styled", "/")
    assert_equal %(<a class="one two three" href="/">styled</a>), styled.link_to("styled", "/")
    assert_equal %(<a class="one two three four" href="/">styled</a>), styled.link_to("styled", "/", class: "four")
  end

  test "with_attributes can be chained off an Attributes instance" do
    attributes = tag.attributes class: "one"

    assert_equal %(<span class="one two">test</span>), tag.with_attributes(attributes, class: "two").span("test")
    assert_equal %(<span class="one two">test</span>), tag.with_attributes(attributes, class: "two").span("test")
    assert_equal %(<span class="one two three">test</span>), tag.with_attributes(attributes, class: "two").span("test", class: "three")
  end

  test "with_attributes chained off an Attributes instance accepts an Attributes instance" do
    base = tag.attributes class: "one"
    attributes = tag.attributes class: "two"
    styled = with_attributes(base, attributes)

    assert_equal %(<span class="one two">test</span>), styled.content_tag(:span, "test")
  end

  test "with_attributes chained off an Attributes instance accepts instances returned from with_attributes" do
    base = with_attributes class: "one"
    styled = base.with_attributes class: "two"

    assert_equal %(<span class="one two">test</span>), styled.content_tag(:span, "test")
  end

  test "with_attributes chained off a TagBuilder instance accept Attributes instances" do
    styled = tag.attributes class: "one two"

    assert_equal %(<a class="one two" href="/">styled</a>), tag.with_attributes(styled).a("styled", href: "/")
  end

  test "with_attributes accepts an empty Hash" do
    assert_equal %(<div></div>), with_attributes({}).tag.div
    assert_equal %(<div></div>), with_attributes(**{}).tag.div
    assert_equal %(<div></div>), tag.with_attributes({}).div
    assert_equal %(<div></div>), tag.with_attributes(**{}).div
  end

  test "tag with arguments on an AttributeMerger instance invokes the method" do
    styled = with_attributes class: "one"

    assert_equal %(<br class="one" />), styled.tag(:br)
  end
end
