module AttributesAndTokenLists::FormBuilderExtensions
  # Inspired by `Object#with_options`, when the `with_attributes` helper
  # is called with a block,
  # it yields a block argument that merges options into a base set of
  # attributes. For example:
  #
  #   form.with_attributes class: "font-bold" do |styled|
  #     styled.text_field :name
  #     #=> <input class="font-bold" type="text" name="name" id="name" />
  #   end
  #
  # When the block is omitted, the object that would be the block
  # parameter is returned:
  #
  #   styled = form.with_attributes class: "font-bold"
  #   styled.text_field :name
  #   #=> <input class="font-bold" type="text" name="name" id="name" />
  #
  def with_attributes(*hashes, **overrides, &block)
    AttributesAndTokenLists::AttributeMerger.new(@template, self, [*hashes, overrides]).with_attributes(&block)
  end
end
