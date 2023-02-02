require "test_helper"

class TagBuilderTest < ActionDispatch::IntegrationTest
  test "reads configuration from config/initializers" do
    post examples_path, params: {template: <<~ERB}
      <%= ui.tag.button "Unstyled" %>
      <%= ui.button.tag "Base" %>
      <%= ui.button.primary "Primary" %>
      <%= ui.button.secondary "Secondary" %>
      <%= ui.button.tertiary "Tertiary" %>
      <%= ui.button.primary.a "Primary", href: "#" %>
      <%= ui.button.primary.link_to "Primary", "#" %>
      <%= ui.button.with(:primary, :secondary, :tertiary).tag "All" %>
    ERB

    assert_button "Unstyled", class: %w[]
    assert_button "Base", class: %w[text-white p-4 focus:outline-none focus:ring]
    assert_button "Primary", class: %w[text-white p-4 focus:outline-none focus:ring bg-green-500]
    assert_button "Secondary", class: %w[text-white p-4 focus:outline-none focus:ring bg-blue-500]
    assert_button "Tertiary", class: %w[text-white p-4 focus:outline-none focus:ring bg-black]
    assert_link "Primary", class: %w[text-white p-4 focus:outline-none focus:ring bg-green-500], href: "#", count: 2
    assert_button "All", class: %w[text-white p-4 focus:outline-none focus:ring bg-green-500 bg-blue-500 bg-black]
  end
end
