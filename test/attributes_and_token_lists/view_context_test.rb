require "test_helper"

class AttributesAndTokenLists::ViewContextTest < ActionView::TestCase
  def builder(&block)
    Class.new(AttributesAndTokenLists::StyledHelper, &block).new(view)
  end

  test "#styled defaults to div" do
    ui = builder do
      def div = styled
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.div.tag "#tag" %>
    ERB

    assert_selector "div", text: "#tag", count: 1
  end

  test "#styled tag can be overridden at the call site" do
    ui = builder do
      def textarea = styled("textarea")
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.textarea.tag.input type: "radio" %>
    ERB

    assert_field count: 1, type: "radio"
  end

  test "#styled accepts a tag_name" do
    ui = builder do
      def button = styled("button")
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.button.tag "#tag" %>
      <%= ui.button.button_tag "#button_tag" %>
    ERB

    assert_button count: 2
    assert_button "#tag"
    assert_button "#button_tag"
  end

  test "#styled accepts defaults directly" do
    ui = builder do
      def rounded = styled(class: "rounded-full")
    end

    assert_equal({class: "rounded-full"}, ui.rounded.to_h)
  end

  test "#styled accepts variants: {defaults: {}}" do
    ui = builder do
      def button = styled("button", variants: {
        defaults: {class: "rounded-full"},
      })
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.button.tag "defaults" %>
      <%= ui.button.tag "override", class: "bg-green-500" %>
    ERB

    assert_button "defaults", class: %w[rounded-full]
    assert_button "override", class: %w[rounded-full bg-green-500]
  end

  test "#styled variant values are available as methods" do
    ui = builder do
      def button = styled("button", variants: {
        color: {primary: {class: "bg-green-500"}}
      })
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.button.primary.tag "Primary" %>
    ERB

    assert_button "Primary", class: %w[bg-green-500]
  end

  test "invoking a method named after multiple variant values raises an error" do
    ui = builder do
      def button = styled("button", variants: {
        text: {big: {class: "text-lg"}},
        spacing: {big: {class: "p-4"}}
      })
    end

    assert_raises AttributesAndTokenLists::ViewContext::VariantCollisionError do
      ui.button.big
    end
  end

  test "variants can accept styled helpers" do
    ui = builder do
      def text = styled("p", variants: {
        defaults: {class: "text-base"},
        size: {heading1: styled("h1", class: "text-2xl")}
      })
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.text.tag "text" %>
      <%= ui.text.link_to "anchor", "#" %>
      <%= ui.text.heading1.tag "heading1" %>
    ERB

    assert_selector "p", text: "text", class: "text-base"
    assert_link "anchor", href: "#", class: "text-base"
    assert_selector "h1", text: "heading1", class: "text-2xl"
  end

  test "#with merges variants by value" do
    ui = builder do
      def button = styled("button", variants: {
        defaults: {class: "rounded-full"},
        color: {primary: {class: "bg-green-500"}}
      })
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.button.with(:primary).tag "positional" %>
      <%= ui.button.with(color: :primary).tag "keywords" %>
    ERB

    assert_button class: %w[rounded-full bg-green-500], text: "positional"
    assert_button class: %w[rounded-full bg-green-500], text: "keywords"
  end

  test "variants can be combined by calls to #with" do
    ui = builder do
      def button = styled("button", variants: {
        color: {primary: {class: "bg-green-500"}},
        border: {rounded: {class: "rounded-full"}}
      })
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.button.with(nil).tag "nil" %>
      <%= ui.button.with(:primary).tag "primary" %>
      <%= ui.button.with(:primary, :rounded).button_tag "primary rounded positional" %>
      <%= ui.button.with([:primary, :rounded]).button_tag "primary rounded array" %>
      <%= ui.button.with(:primary, border: :rounded).button_tag "primary border rounded" %>
    ERB

    assert_button "nil", class: []
    assert_button "primary", exact: true, class: %w[bg-green-500]
    assert_button "primary rounded positional", exact: true, class: %w[bg-green-500 rounded-full]
    assert_button "primary rounded array", exact: true, class: %w[bg-green-500 rounded-full]
    assert_button "primary border rounded", exact: true, class: %w[bg-green-500 rounded-full]
  end

  test "invoking #with with a block delegates to #with_attributes" do
    ui = builder do
      def button = styled("button", variants: {
        color: {primary: {class: "bg-green-500"}},
      })
    end

    render inline: <<~ERB, locals: {ui: ui}
      <% ui.button.with(color: :primary) do |styled| %>
        <%= styled.tag "Primary" %>
      <% end %>
    ERB

    assert_button "Primary", exact: true, class: %w[bg-green-500]
  end

  test "#tag for void elements renders as HTML" do
    ui = builder do
      def input = styled("input", class: "rounded-full")
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= ui.input.tag %>
    ERB

    assert_equal %(<input class="rounded-full">), rendered.strip
  end

  test "#call is an alias for #merge" do
    ui = builder do
      def button = styled("button", class: "rounded-full")
    end

    assert_equal({class: "rounded-full bg-green-500"}, ui.button.(class: "bg-green-500").to_h)
  end

  test "#with_attributes accepts an AttributesAndTokenLists::ViewContext instance" do
    ui = builder do
      def button = styled("button", class: "rounded-full")
    end

    render inline: <<~ERB, locals: {ui: ui}
      <% with_attributes ui.button, class: "font-medium" do |styled| %>
        <%= styled.button_tag "Submit" %>
      <% end %>
    ERB

    assert_button "Submit", class: %w[rounded-full font-medium], type: "submit"
  end

  test "Object#with_options accepts AttributesAndTokenLists::ViewContext instance" do
    ui = builder do
      def button = styled("button", class: "rounded-full")
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= fields do |form| %>
        <%= form.with_options(ui.button).button "As Options" %>
      <% end %>
    ERB

    assert_button "As Options", class: %(rounded-full), type: "submit"
  end

  test "#to_hash splats into Action View helpers" do
    ui = builder do
      def button = styled("button", class: "rounded-full")
    end

    render inline: <<~ERB, locals: {ui: ui}
      <%= fields do |form| %>
        <%= form.button "As Options", **ui.button %>
        <%= form.button "Chained Call", **ui.button.(class: "btn") %>
      <% end %>
    ERB

    assert_button "As Options", class: %(rounded-full), type: "submit"
    assert_button "Chained Call", class: %(rounded-full btn), type: "submit"
  end

  test "#to_s delegates to ActionView::Attributes" do
    ui = builder do
      def attrs = styled(class: "rounded-full")
    end

    rendered = ui.attrs.to_s

    assert_equal %(class="rounded-full"), rendered
  end

  test "cannot name a variant after an existing method" do
    ui = builder do
      def button = styled(variants: {with: {class: "will fail"}})
    end

    exception = assert_raises do
      ui.button.with(:with)
    end

    assert_includes exception.message, %(Cannot define :with)
  end
end
