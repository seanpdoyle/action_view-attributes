module AttributesAndTokenLists::Helper
  extend ActiveSupport::Concern

  class_methods do
    def html_attributes(name, &block)
      AttributesAndTokenLists.html_attributes(name, self, &block)
    end
  end
end
