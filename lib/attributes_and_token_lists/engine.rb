require "attributes_and_token_lists/backports"
require "attributes_and_token_lists/form_builder_extensions"

module AttributesAndTokenLists
  class Engine < ::Rails::Engine
    config.attributes_and_token_lists = ActiveSupport::OrderedOptions.new
    config.attributes_and_token_lists.builders = {}

    config.to_prepare do
      if ::ActionView::VERSION::MAJOR == 6
        ActionView::Helpers::TagHelper::TagBuilder.include AttributesAndTokenLists::Backports
      end

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
