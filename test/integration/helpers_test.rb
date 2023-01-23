require "test_helper"

class HelpersTest < ActionDispatch::IntegrationTest
  test "mixes helper into host Rails Application" do
    post examples_path, params: {template: <<~ERB}
      <%= tag.attributes({id: 1, class: "one"}, {hidden: true}, class: "two").tag.button %>
    ERB

    assert_html_equal <<~HTML, response.body
      <button id="1" class="one two" hidden="hidden"></button>
    HTML
  end

  test "merges attributes into **keyword arguments" do
    post examples_path, params: {template: <<~ERB}
      <%= with_attributes(class: "attribute-default").with_options(class: "options-default").form_with class: "override" %>
    ERB

    assert_html_equal <<~HTML, response.body
      <form class="attribute-default options-default override" action="/examples" accept-charset="UTF-8" method="post">
    HTML
  end

  test "merges attributes into **keyword arguments passed with a block" do
    post examples_path, params: {template: <<~ERB}
      <%= with_attributes(class: "attribute-default").with_options(class: "options-default").form_with class: "override", authenticity_token: false, enforce_utf8: false do %>
      <% end %>
    ERB

    assert_html_equal <<~HTML, response.body
      <form class="attribute-default options-default override" action="/examples" accept-charset="UTF-8" method="post">
      </form>
    HTML
  end

  test "extends FormBuilder instances with_attributes (block)" do
    post examples_path, params: {template: <<~ERB}
      <%= fields do |form| %>
        <% form.with_attributes class: "font-bold" do |special_form| %>
          <%= special_form.text_field :text, class: "text" %>
        <% end %>
        <% form.with_options class: "font-bold" do |special_form| %>
          <%= special_form.text_field :text, class: "text" %>
        <% end %>
      <% end %>
    ERB

    assert_html_equal <<~HTML, response.body
      <input class="font-bold text" type="text" name="text" id="text" />
      <input class="font-bold text" type="text" name="text" id="text" />
    HTML
  end

  test "extends FormBuilder instances with_attributes (instance)" do
    post examples_path, params: {template: <<~ERB}
      <%= fields do |form| %>
        <%= form.with_attributes(class: "font-bold").text_field :text, class: "text" %>
        <%= form.with_options(class: "font-bold").text_field :text, class: "text" %>
      <% end %>
    ERB

    assert_html_equal <<~HTML, response.body
      <input class="font-bold text" type="text" name="text" id="text" />
      <input class="font-bold text" type="text" name="text" id="text" />
    HTML
  end

  def assert_html_equal(expected, actual, *rest)
    assert_equal expected.squish, actual.squish, *rest
  end
end
