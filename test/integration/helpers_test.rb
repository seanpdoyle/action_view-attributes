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
end
