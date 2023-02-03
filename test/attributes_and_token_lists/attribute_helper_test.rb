require "test_helper"

class AttributesAndTokenLists::AttributeHelperTest < ActionView::TestCase
  test "AttributesAndTokenLists.tag_builder declares helper" do
    html_attributes :ui
    html_attributes :another_ui

    assert_respond_to view, :ui
    assert_respond_to view, :another_ui
  end

  test "definitions yield the builder as an argument" do
    html_attributes :ui do |ui|
      assert_respond_to ui, :variants
    end

    assert_respond_to view, :ui
  end

  test "definitions can omit the builder argument from the block" do
    html_attributes :ui do
      variant :rounded, class: "rounded-full"
    end

    assert_equal({class: "rounded-full"}, view.ui.rounded)
  end

  test "definitions can define nested builders" do
    html_attributes :ui do
      variant :button, class: "rounded-full" do
        variant :primary, class: "bg-green-500"
      end
    end

    render inline: <<~ERB
      <%= ui.tag.button "Base" %>
      <%= ui.button.tag.button "Primary" %>
      <%= ui.button.primary.button_tag "Primary" %>
    ERB

    assert_button "Base", class: %w[rounded-full]
    assert_button "Primary", class: %w[rounded-full bg-green-500], count: 2
  end

  test "variants can be applied by calling #with" do
    html_attributes :ui do
      variants style: {primary: {class: "bg-green-500"}}
    end

    render inline: <<~ERB
      <%= ui.with(:primary).button_tag "Primary positional" %>
      <%= ui.with(style: :primary).button_tag "Primary keyword" %>
    ERB

    assert_button "Primary positional", class: %w[bg-green-500]
    assert_button "Primary keyword", class: %w[bg-green-500]
  end

  test "variants can be combined by calls to #with" do
    html_attributes :button do
      variants  style: {primary: {class: "bg-green-500"}},
                border: {rounded: {class: "rounded-full"}}
    end

    render inline: <<~ERB
      <%= ui.with(nil).tag "Base" %>
      <%= ui.with(:primary).tag "Primary" %>
      <%= ui.with(:primary, :rounded).button_tag "Primary Rounded" %>
      <%= ui.with([:primary, :rounded]).button_tag "Primary Rounded Array" %>
      <%= ui.with(:primary, border: :rounded).button_tag "Primary Border Rounded" %>
    ERB

    assert_button "Base", class: false
    assert_button "Primary", exact: true, class: %w[bg-green-500]
    assert_button "Secondary", exact: true, class: %w[bg-red-500]
    assert_button "Primary Rounded", exact: true, class: %w[bg-green-500 rounded-full]
    assert_button "Primary Rounded Array", exact: true, class: %w[bg-green-500 rounded-full]
    assert_button "Primary Border Rounded", exact: true, class: %w[bg-red-500 rounded-full]
  end

  test "#to_hash splats into Action View helpers" do
    html_attributes :ui do
      variant :button, class: "rounded-full"
    end

    render inline: <<~ERB
      <%= fields do |form| %>
        <%= form.button "As Options", ui.button %>
        <%= form.button "Chained Call", ui.button.(class: "btn") %>
      <% end %>
    ERB

    assert_button "As Options", class: %(rounded-full), type: "submit"
    assert_button "Chained Call", class: %(rounded-full btn), type: "submit"
  end

  test "#with_attributes accepts an AttributeHelper instance" do
    html_attributes :ui do
      variant :button, class: "rounded-full"
    end

    render inline: <<~ERB
      <% with_attributes ui.button, class: "font-medium" do |styled| %>
        <%= styled.button_tag "Submit" %>
      <% end %>
    ERB

    assert_button "Submit", class: %w[rounded-full font-medium], type: "submit"
  end

  test "#to_s delegates to ActionView::Attributes" do
    html_attributes :ui do
      variant :button, class: "rounded-full"
    end

    rendered = view.ui.button.to_s

    assert_equal %(class="rounded-full"), rendered
  end

  test "cannot name a variant after an existing method" do
    collision = :with

    exception = assert_raises do
      html_attributes(:ui) { variant collision }
    end

    assert_includes exception.message, %(Cannot define "#{collision}", it's already defined)
  end

  test "cannot name a base after an existing method" do
    collision = :with
    exception = assert_raises do
      html_attributes :ui do
        variant(:button) { variant collision }
      end
    end

    assert_includes exception.message, %(Cannot define "#{collision}", it's already defined)
  end

  def html_attributes(...)
    view.extend AttributesAndTokenLists.html_attributes(...)
  end
end
