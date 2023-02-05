require "action_view/attributes"

class ActionView::Attributes::Engine < Rails::Engine
  initializer "action_view.with_options" do
    if Rails.version < "7.0"
      require "action_view/attributes/with_options_backport"

      Object.include ActionView::Attributes::WithOptionsBackport
    end
  end

  initializer "action_view.attributes" do
    require "action_view/attributes/tag_builder"

    ActionView::Helpers::TagHelper::TagBuilder.include ActionView::Attributes::TagBuilder

    ActionView::Attributes.token_lists = [
      "class",
      "rel",
      "aria-controls",
      "aria-describedby",
      "aria-details",
      "aria-dropeffect",
      "aria-flowto",
      "aria-keyshortcuts",
      "aria-labelledby",
      "aria-owns",
      "aria-relevant",
      "data-action",
      "data-controller",
      /data-(.*)-target/
    ].to_set
  end
end
