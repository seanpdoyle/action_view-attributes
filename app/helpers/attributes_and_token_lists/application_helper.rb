module AttributesAndTokenLists::ApplicationHelper
  # Inspired by `Object#with_options`, when the `with_attributes` helper
  # is called with a block,
  # it yields a block argument that merges options into a base set of
  # attributes. For example:
  #
  #   with_attributes class: "border rounded-sm p-4" do |styled|
  #     styled.link_to "I'm styled!", "/"
  #     #=> <a class="border rounded-sm p-4" href="/">I'm styled!</a>
  #   end
  #
  # When the block is omitted, the object that would be the block
  # parameter is returned:
  #
  #   styled = with_attributes class: "border rounded-sm p-4"
  #   styled.link_to "I'm styled!", "/"
  #   #=> <a class="border rounded-sm p-4" href="/">I'm styled!</a>
  #
  # To change the receiver from the view context, invoke
  # <tt>with_attributes</tt> an the instance returned from another
  # <tt>with_attributes</tt> call:
  #
  #   button = with_attributes class: "border rounded-sm p-4"
  #   button.link_to "I have a border", "/"
  #   #=> <a class="border rounded-sm p-4" href="/">I have a border</a>
  #
  #   primary = button.with_attributes class: "text-red-500 border-red-500"
  #   primary.link_to "I have a red border", "/"
  #   #=> <a class="border rounded-sm p-4 text-red-500 border-red-500" href="/">I have a red border</a>
  #
  #   secondary = button.with_attributes class: "text-blue-500 border-blue-500"
  #   secondary.link_to "I have a blue border", "/"
  #   #=> <a class="border rounded-sm p-4 text-blue-500 border-blue-500" href="/">I have a blue border</a>
  #
  ruby2_keywords def with_attributes(*values, &block)
    with_options(tag.attributes(*values), &block)
  end
end
