class AttributesAndTokenLists::StyledHelper
  def initialize(view_context, &block)
    @view_context = view_context

    instance_exec(&block) if block
  end

  def styled(...)
    AttributesAndTokenLists::ViewContext.new(@view_context, ...)
  end
end
