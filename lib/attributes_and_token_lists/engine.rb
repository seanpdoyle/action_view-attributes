require "attributes_and_token_lists/backports"

module AttributesAndTokenLists
  class Engine < ::Rails::Engine
    config.to_prepare do
      if ::ActionView::VERSION::MAJOR == 6
        ActionView::Helpers::TagHelper::TagBuilder.include AttributesAndTokenLists::Backports
      end
    end
  end
end
