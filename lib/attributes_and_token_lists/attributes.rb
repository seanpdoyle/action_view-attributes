require "action_view/attributes"
require "action_view/helpers/tag_helper/tag_builder"

module AttributesAndTokenLists::Attributes
  extend ActiveSupport::Concern

  included do
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
  end

  def aria(values)
    merge(aria: values)
  end

  def data(values)
    merge(data: values)
  end
end
