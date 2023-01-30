require "test_helper"

class TagBuilderTest < ActionDispatch::IntegrationTest
  test "reads configuration from app/views/initializers" do
    post examples_path, params: {template: <<~ERB}
      <%= view_initializer.tag.button "Unstyled" %>
      <%= view_initializer.button.tag "Base" %>
      <%= view_initializer.button.primary "Primary" %>
      <%= view_initializer.button.secondary "Secondary" %>
      <%= view_initializer.button.tertiary "Tertiary" %>
      <%= view_initializer.button.primary.a "Primary", href: "#" %>
      <%= view_initializer.button.primary.link_to "Primary", "#" %>
      <%= view_initializer.button.with(:primary, :secondary, :tertiary).tag "All" %>
    ERB

    assert_button "Unstyled", class: %w[]
    assert_button "Base", class: %w[text-white p-4 focus:outline-none focus:ring]
    assert_button "Primary", class: %w[text-white p-4 focus:outline-none focus:ring bg-green-500]
    assert_button "Secondary", class: %w[text-white p-4 focus:outline-none focus:ring bg-blue-500]
    assert_button "Tertiary", class: %w[text-white p-4 focus:outline-none focus:ring bg-black]
    assert_link "Primary", class: %w[text-white p-4 focus:outline-none focus:ring bg-green-500], href: "#", count: 2
    assert_button "All", class: %w[text-white p-4 focus:outline-none focus:ring bg-green-500 bg-blue-500 bg-black]
  end

  test "reads configuration from config/initializers" do
    post examples_path, params: {template: <<~ERB}
      <%= initializer.tag.button "Unstyled" %>
      <%= initializer.button.tag "Base" %>
      <%= initializer.button.primary "Primary" %>
      <%= initializer.button.secondary "Secondary" %>
      <%= initializer.button.tertiary "Tertiary" %>
      <%= initializer.button.primary.a "Primary", href: "#" %>
      <%= initializer.button.primary.link_to "Primary", "#" %>
      <%= initializer.button.with(:primary, :secondary, :tertiary).tag "All" %>
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
