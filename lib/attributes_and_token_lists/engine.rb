require "attributes_and_token_lists/helper"

module AttributesAndTokenLists
  class Engine < ::Rails::Engine
    initializer "attributes_and_token_lists.core_ext" do
      if Rails.version < "7.0"
        require "attributes_and_token_lists/object_backports"
      end
    end

    ActiveSupport.on_load :action_view do
      require "attributes_and_token_lists/attributes"

      ActionView::Attributes.include AttributesAndTokenLists::Attributes
    end
  end
end
