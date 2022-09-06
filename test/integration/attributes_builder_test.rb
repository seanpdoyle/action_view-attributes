require "test_helper"

class AttributesBuilderTest < ActionDispatch::IntegrationTest
  test "reads configuration from app/views/initializers" do
    post examples_path, params: {template: <<~ERB}
      <%= atl.tag.button "Unstyled" %>
      <%= atl.button.tag "Base" %>
      <%= atl.button.primary.tag "Primary" %>
      <%= atl.button.secondary.tag "Secondary" %>
      <%= atl.button.tertiary.tag "Tertiary" %>
      <%= atl.button.primary.tag.a "Primary", href: "#" %>
      <%= atl.button.primary.link_to "Primary", "#" %>
    ERB

    assert_button "Unstyled", class: []
    assert_button "Base", class: %w[text-white p-4 focus:outline-none focus:ring]
    assert_button "Primary", class: %w[text-white p-4 focus:outline-none focus:ring bg-green-500]
    assert_button "Secondary", class: %w[text-white p-4 focus:outline-none focus:ring bg-blue-500]
    assert_button "Tertiary", class: %w[text-white p-4 focus:outline-none focus:ring bg-black]
    assert_link "Primary", href: "#", class: %w[text-white p-4 focus:outline-none focus:ring bg-green-500], count: 2
  end
end
