require "test_helper"

class HelpersTest < ActionDispatch::IntegrationTest
  test "mixes helper into host Rails Application" do
    post examples_path, params: {template: <<~ERB}
      <%= tag.attributes({id: 1, class: "one"}, {hidden: true}, class: "two").tag.button %>
    ERB

    assert_equal <<~HTML, response.body
      <button id="1" class="one two" hidden="hidden"></button>
    HTML
  end

  test "extends FormBuilder instances with_attributes (block)" do
    post examples_path, params: {template: <<~ERB}
      <%= form_with url: "/", authenticity_token: false, enforce_utf8: false do |form| %>
        <% form.with_attributes class: "font-bold" do |special_form| %>
          <%= special_form.text_field :text, class: "text" %>
        <% end %>
      <% end %>
    ERB

    assert_equal <<~HTML.strip, response.body
      <form action="/" accept-charset="UTF-8" method="post">
          <input class="font-bold text" type="text" name="text" id="text" />
      </form>
    HTML
  end

  test "extends FormBuilder instances with_attributes (instance)" do
    post examples_path, params: {template: <<~ERB}
      <%= form_with url: "/", authenticity_token: false, enforce_utf8: false do |form| %>
        <%= form.with_attributes(class: "font-bold").text_field :text, class: "text" %>
      <% end %>
    ERB

    assert_equal <<~HTML.strip, response.body
      <form action="/" accept-charset="UTF-8" method="post">
        <input class="font-bold text" type="text" name="text" id="text" />
      </form>
    HTML
  end
end
