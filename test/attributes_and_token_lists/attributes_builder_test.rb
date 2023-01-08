require "test_helper"
require "capybara/minitest"

class AttributesAndTokenLists::AttributesBuilderTest < ActionView::TestCase
  include Capybara::Minitest::Assertions

  test "AttributesAndTokenLists.define declares helper" do
    define_builder_helper_method :test_builder
    define_builder_helper_method :another_builder

    assert view.respond_to?(:test_builder), "declares helper methods"
    assert view.respond_to?(:another_builder), "declares helper methods"
  end

  test "definitions yield the builder as an argument" do
    define_builder_helper_method :builder do |instance|
      instance.base :rounded, class: "rounded-full"
    end

    render inline: <<~ERB
      <%= builder.rounded.tag "Content" %>
    ERB

    assert_css "div", class: "rounded-full", text: "Content"
  end

  test "definitions can omit the builder argument from the block" do
    define_builder_helper_method :builder do
      base :rounded, class: "rounded-full"
    end

    render inline: <<~ERB
      <%= builder.rounded.tag "Content" %>
    ERB

    assert_css "div", class: "rounded-full", text: "Content"
  end

  test "definitions can declare a default tag with the tag_name: option" do
    define_builder_helper_method :builder do
      base :button, tag_name: :button, class: "rounded-full"
    end

    render inline: <<~ERB
      <%= builder.button.tag "Submit" %>
      <%= builder.button.button_tag "Submit" %>
    ERB

    assert_button "Submit", class: "rounded-full", count: 2
  end

  test "definitions can define other variants" do
    define_builder_helper_method :builder do
      base :button, tag_name: :button, class: "rounded-full" do
        variant :primary, class: "bg-green-500"
      end
    end

    render inline: <<~ERB
      <%= builder.button.tag "Base" %>
      <%= builder.button.primary.tag "Primary" %>
      <%= builder.button.primary.button_tag "Primary" %>
    ERB

    assert_button "Base", class: %w[rounded-full]
    assert_button "Primary", class: %w[rounded-full bg-green-500], count: 2
  end

  test "variants can be combined" do
    define_builder_helper_method :builder do
      base :button, tag_name: :button do
        variant :primary, class: "bg-green-500"
        variant :rounded, class: "rounded-full"
      end
    end

    render inline: <<~ERB
      <%= builder.button[nil].tag "Base" %>
      <%= builder.button[:primary].tag "Primary" %>
      <%= builder.button[:primary, :rounded].button_tag "Primary Rounded" %>
      <%= builder.button[[:primary, :rounded]].button_tag "Primary Rounded Array" %>
    ERB

    assert_button "Base", class: %w[]
    assert_button "Primary", exact: true, class: %w[bg-green-500], count: 1
    assert_button "Primary Rounded", exact: true, class: %w[bg-green-500 rounded-full], count: 1
    assert_button "Primary Rounded Array", exact: true, class: %w[bg-green-500 rounded-full], count: 1
  end

  test "defined attributes can render with content" do
    define_builder_helper_method :builder do
      base :button, tag_name: :button
    end

    render inline: <<~ERB
      <%= builder.button.tag "Submit" %>
    ERB

    assert_button "Submit"
  end

  test "defined attributes can render without content" do
    define_builder_helper_method :builder do
      base :input, tag_name: :input do
        variant :text, type: "text"
        variant :submit, type: "submit"
      end
    end

    render inline: <<~ERB
      <%= builder.input.tag value: "Default" %>
      <%= builder.input.text.tag value: "Text" %>
      <%= builder.input.submit.tag value: "Submit"%>
    ERB

    assert_field(with: "Default", exact: true, count: 1) { _1["type"].nil? }
    assert_field(type: "text", with: "Text", count: 1)
    assert_button("Submit", type: "submit", count: 1)
  end

  test "defined attributes can render with overrides" do
    define_builder_helper_method :builder do
      base :button, tag_name: :button, type: "submit"
    end

    render inline: <<~ERB
      <%= builder.button.tag "Submit" %>
      <%= builder.button.tag "Reset", type: "reset" %>
    ERB

    assert_button "Submit", type: "submit"
    assert_button "Reset", type: "reset"
  end

  test "defined attributes can render as other tags" do
    define_builder_helper_method :builder do
      base :button, tag_name: :button, class: "rounded-full"
    end

    render inline: <<~ERB
      <%= builder.button.tag "A button" %>
      <%= builder.button.tag.input value: "An input", type: "button" %>
      <%= builder.button.tag.a "A link", href: "#" %>
    ERB

    assert_button "A button", class: "rounded-full"
    assert_field with: "An input", class: "rounded-full", type: "button"
    assert_link "A link", class: "rounded-full", href: "#"
  end

  test "defined attributes splat into Action View helpers" do
    define_builder_helper_method :builder do
      base :button, tag_name: :button, class: "rounded-full"
    end

    render inline: <<~ERB
      <%= form_with scope: :post, url: "/" do |form| %>
        <%= form.button "Submit", builder.button.(class: "btn") %>
      <% end %>
    ERB

    assert_css "form" do
      assert_button "Submit", class: %w[rounded-full btn], type: "submit"
    end
  end

  def page
    @page ||= Capybara.string(rendered)
  end

  def define_builder_helper_method(name, &block)
    AttributesAndTokenLists.builder(name, &block)
    view.extend(AttributesAndTokenLists.define_builder_helper_methods(Module.new))
  end
end
