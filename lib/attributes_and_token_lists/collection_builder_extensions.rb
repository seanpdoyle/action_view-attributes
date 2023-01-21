module AttributesAndTokenLists::CollectionBuilderExtensions
  # Inspired by `Object#with_options`, when the `with_attributes` helper
  # is called with a block,
  # it yields a block argument that merges options into a base set of
  # attributes. For example:
  #
  #   builder.with_attributes class: "font-bold" do |styled|
  #     styled.check_box
  #     #=> <input class="font-bold" type="checkbox" value="a" name="record[choice][]" id="record_choice_a" />
  #   end
  #
  # When the block is omitted, the object that would be the block
  # parameter is returned:
  #
  #   styled = builder.with_attributes class: "font-bold"
  #   styled.check_box
  #   #=> <input class="font-bold" type="checkbox" value="a" name="record[choice][]" id="record_choice_a" />
  #
  def with_attributes(*hashes, **overrides, &block)
    attribute_merger = AttributesAndTokenLists::AttributeMerger.new(@template_object, self, [@input_html_options])

    attribute_merger.with_attributes(*hashes, **overrides, &block)
  end
  alias_method :with_options, :with_attributes
end

ActiveSupport.on_load :action_view do
  require "action_view/helpers/tags/collection_helpers"

  ActionView::Helpers::Tags::CollectionHelpers::Builder.include AttributesAndTokenLists::CollectionBuilderExtensions
rescue LoadError
  # skip extension
end
