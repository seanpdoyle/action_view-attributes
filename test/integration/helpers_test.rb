require "test_helper"

class HelpersTest < ActionDispatch::IntegrationTest
  test "mixes helper into host Rails Application" do
    post examples_path, params: {template: <<~ERB}
      <%= tag.with_attributes({id: 1, class: "one"}, {hidden: true}, class: "two").button %>
    ERB

    assert_html_equal <<~HTML, response.body
      <button id="1" class="one two" hidden="hidden"></button>
    HTML
  end

  test "extends FormBuilder#with_options accepts tag.attributes (block)" do
    post examples_path, params: {template: <<~ERB}
      <%= form_with url: "/", authenticity_token: false, enforce_utf8: false do |form| %>
        <% form.with_options tag.attributes(class: "font-bold") do |special_form| %>
          <%= special_form.text_field :text, class: "text" %>
        <% end %>
      <% end %>
    ERB

    assert_html_equal <<~HTML, response.body
      <form action="/" accept-charset="UTF-8" method="post">
          <input class="font-bold text" type="text" name="text" id="text" />
      </form>
    HTML
  end

  test "extends FormBuilder#with_options accepts tag.attributes (instance)" do
    post examples_path, params: {template: <<~ERB}
      <%= form_with url: "/", authenticity_token: false, enforce_utf8: false do |form| %>
        <%= form.with_options(tag.attributes(class: "font-bold")).text_field :text, class: "text" %>
      <% end %>
    ERB

    assert_html_equal <<~HTML, response.body
      <form action="/" accept-charset="UTF-8" method="post">
        <input class="font-bold text" type="text" name="text" id="text" />
      </form>
    HTML
  end

  test "extends collection Builder#with_options accepts tag.attributes (block)" do
    post examples_path, params: {template: <<~ERB}
      <%= collection_check_boxes :record, :choice, ["a"], :to_s, :to_s, {include_hidden: false} do |builder| %>
          <% builder.with_options tag.attributes(class: "default") do |special_builder| %>
            <%= special_builder.check_box class: "override" %>
          <% end %>
        <% end %>
    ERB

    assert_html_equal <<~HTML, response.body
      <input class="default override" type="checkbox" value="a" name="record[choice][]" id="record_choice_a" />
    HTML
  end

  test "extends collection Builder#with_options accepts tag.attributes (instance)" do
    post examples_path, params: {template: <<~ERB}
      <%= collection_check_boxes :record, :choice, ["a"], :to_s, :to_s, {include_hidden: false} do |builder| %>
        <%= builder.with_options(tag.attributes(class: "default")).check_box class: "override" %>
      <% end %>
    ERB

    assert_html_equal <<~HTML, response.body
      <input class="default override" type="checkbox" value="a" name="record[choice][]" id="record_choice_a" />
    HTML
  end

  def assert_html_equal(expected, actual, *rest)
    assert_equal expected.squish, actual.squish, *rest
  end
end
