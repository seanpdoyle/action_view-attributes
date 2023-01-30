module AttributesAndTokenLists
  class Engine < ::Rails::Engine
    config.attributes_and_token_lists = ActiveSupport::OrderedOptions.new
    config.attributes_and_token_lists.builders = {}

    initializer "attributes_and_token_lists.core_ext" do
      if Rails.version < "7.0"
        require "attributes_and_token_lists/object_backports"
      end
    end

    ActiveSupport.on_load :action_view do
      require "action_view/attributes"
      require "action_view/helpers/tag_helper/tag_builder"

      ActionView::Attributes.class_eval do
        self.token_lists = [
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

        def aria(values)
          merge(aria: values)
        end

        def data(values)
          merge(data: values)
        end
      end
    end

    config.to_prepare do
      AttributesAndTokenLists.config = ::Rails.configuration.attributes_and_token_lists

      begin
        ApplicationController.renderer.render(template: "initializers/attributes_and_token_lists")
      rescue ActionView::MissingTemplate
      end
      ActiveSupport.run_load_hooks :attributes_and_token_lists, AttributesAndTokenLists

      AttributesAndTokenLists.define_builder_helper_methods(ActionView::Base)
    end
  end
end
