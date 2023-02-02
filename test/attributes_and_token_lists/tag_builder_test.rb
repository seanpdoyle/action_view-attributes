require "test_helper"
require "capybara/minitest"

class AttributesAndTokenLists::TagBuilderTest < ActionView::TestCase
  include Capybara::Minitest::Assertions

  test "AttributesAndTokenLists.tag_builder declares helper" do
    tag_builder :ui
    tag_builder :another_ui

    assert_respond_to view, :ui
    assert_respond_to view, :another_ui
  end

  test "definitions yield the builder as an argument" do
    tag_builder :ui do |ui|
      assert_respond_to ui, :base
      assert_respond_to ui, :variant
      assert_includes ui.ancestors, AttributesAndTokenLists::TagBuilder
    end

    assert_respond_to view, :ui
  end

  test "definitions can omit the builder argument from the block" do
    tag_builder :ui do |ui|
      ui.builder :rounded, class: "rounded-full"
    end

    render inline: <<~ERB
      <%= ui.rounded.tag "Content" %>
    ERB

    assert_css "div", class: "rounded-full", text: "Content"
  end

  test "definitions can declare a default tag by calling #as with base attributes" do
    tag_builder :ui do
      builder :button do
        as :button, class: "rounded-full"
      end
    end

    render inline: <<~ERB
      <%= ui.button.tag "Submit" %>
      <%= ui.button.button_tag "Submit" %>
    ERB

    assert_button "Submit", class: "rounded-full", count: 2
  end

  test "definitions can declare a default tag by chaining #as" do
    tag_builder :ui do
      builder(:button).as(:button, class: "rounded-full")
    end

    render inline: <<~ERB
      <%= ui.button.tag "Submit" %>
      <%= ui.button.button_tag "Submit" %>
    ERB

    assert_button "Submit", class: "rounded-full", count: 2
  end

  test "definitions can define nested builders" do
    tag_builder :ui do
      builder :button do
        as :button, class: "rounded-full"
        builder :primary, class: "bg-green-500"
      end
    end

    render inline: <<~ERB
      <%= ui.button.tag "Base" %>
      <%= ui.button.primary.tag "Primary" %>
      <%= ui.button.primary.button_tag "Primary" %>
    ERB

    assert_button "Base", class: %w[rounded-full]
    assert_button "Primary", class: %w[rounded-full bg-green-500], count: 2
  end

  test "definitions can define nested builders in an #as call's block" do
    tag_builder :ui do
      builder(:button).as(:button, class: "rounded-full") do
        builder :primary, class: "bg-green-500"
      end
    end

    render inline: <<~ERB
      <%= ui.button.tag "Base" %>
      <%= ui.button.primary.tag "Primary" %>
      <%= ui.button.primary.button_tag "Primary" %>
    ERB

    assert_button "Base", class: %w[rounded-full]
    assert_button "Primary", class: %w[rounded-full bg-green-500], count: 2
  end

  test "variants can be composed by calling #with" do
    tag_builder :ui do
      builder :button do
        as :button, class: "focus:outline-none focus:ring"

        variant :style, {
          primary: {class: "bg-green-500"}
        }
      end
    end

    render inline: <<~ERB
      <%= ui.button.tag "Base" %>
      <%= ui.button.with(style: :primary).tag "Primary" %>
      <%= ui.button.with(style: :primary).button_tag "Primary" %>
    ERB

    assert_button "Base", class: %w[focus:outline-none focus:ring]
    assert_button "Primary", class: %w[focus:outline-none focus:ring bg-green-500], count: 2
  end

  test "variants can be combined by calls to #with" do
    tag_builder :ui do |ui|
      ui.builder(:button).as(:button) do |button|
        button.variants style: {
          primary: {class: "bg-green-500"},
          secondary: {class: "bg-red-500"}
        }

        variant :border, {
          rounded: {class: "rounded-full"}
        }
      end
    end

    render inline: <<~ERB
      <%= ui.button.with(nil).tag "Base" %>
      <%= ui.button.with(:primary).tag "Primary" %>
      <%= ui.button.with(:secondary).tag "Primary" %>
      <%= ui.button.with(:primary, :rounded).button_tag "Primary Rounded" %>
      <%= ui.button.with([:primary, :rounded]).button_tag "Primary Rounded Array" %>
      <%= ui.button.with(:rounded, style: :secondary).button_tag "Rounded Secondary Hash" %>
    ERB

    assert_button "Base", class: %w[]
    assert_button "Primary", exact: true, class: %w[bg-green-500], count: 1
    assert_button "Secondary", exact: true, class: %w[bg-red-500], count: 1
    assert_button "Primary Rounded", exact: true, class: %w[bg-green-500 rounded-full], count: 1
    assert_button "Primary Rounded Array", exact: true, class: %w[bg-green-500 rounded-full], count: 1
    assert_button "Rounded Secondary Hash", exact: true, class: %w[bg-red-500 rounded-full], count: 1
  end

  test "#tag with content" do
    tag_builder :ui do
      builder(:ui).as(:button)
    end

    render inline: <<~ERB
      <%= ui.button.tag "Submit" %>
    ERB

    assert_button "Submit"
  end

  test "#tag without content" do
    tag_builder :builder do
      builder :input do
        as :input

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

  test "#tag with overrides" do
    tag_builder :builder do
      builder(:button).as :button, type: "submit"
    end

    render inline: <<~ERB
      <%= builder.button.tag "Submit" %>
      <%= builder.button.tag "Reset", type: "reset" %>
    ERB

    assert_button "Submit", type: "submit"
    assert_button "Reset", type: "reset"
  end

  test "#tag as other tags" do
    tag_builder :builder do
      builder(:button).as :button, class: "rounded-full"
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

  test "#to_hash splats into Action View helpers" do
    tag_builder :ui do
      builder :button, class: "rounded-full"
    end

    render inline: <<~ERB
      <%= fields do |form| %>
        <%= form.button "As Options", ui.button %>
        <%= form.button "Chained Call", ui.button.(class: "btn") %>
      <% end %>
    ERB

    assert_button "As Options", class: %(rounded-full), type: "submit", count: 1
    assert_button "Chained Call", class: %(rounded-full btn), type: "submit", count: 1
  end

  test "AttributesAndTokenLists::ApplicationHelper#with_attributes accepts a TagBuilder instance" do
    tag_builder :ui do
      builder :button, class: "rounded-full"
    end

    render inline: <<~ERB
      <% with_attributes ui.button, class: "btn" do |styled| %>
        <%= styled.button_tag "Submit" %>
      <% end %>
    ERB

    assert_button "Submit", class: %w[rounded-full btn], type: "submit"
  end

  test "#to_s delegates to ActionView::Attributes" do
    tag_builder :ui do
      builder :button, class: "rounded-full"
    end

    rendered = view.ui.button.to_s

    assert_equal %(class="rounded-full"), rendered
  end

  test "cannot name a variant after an existing method" do
    collision = :with

    exception = assert_raises do
      tag_builder(:ui) { builder collision }
    end

    assert_includes exception.message, %(Cannot define "#{collision}", it's already defined)
  end

  test "cannot name a base after an existing method" do
    collision = :with
    exception = assert_raises do
      tag_builder :ui do
        builder(:button) { variant collision }
      end
    end

    assert_includes exception.message, %(Cannot define "#{collision}", it's already defined)
  end

  def page
    @page ||= Capybara.string(rendered)
  end

  def tag_builder(name, &block)
    AttributesAndTokenLists.tag_builder(name, &block)
    view.extend(AttributesAndTokenLists.define_builder_helper_methods(Module.new))
  end
end
