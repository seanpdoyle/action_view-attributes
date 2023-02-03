class AttributesAndTokenLists::Builder
  def initialize(configuration, view_context, *attributes)
    self.configuration = configuration
    self.view_context = view_context
    self.attributes = view_context.tag.attributes(*attributes)

    configuration.configure(self) do |values|
      view_context.tag.attributes(*values)
    end
  end

  def merge!(...)
    tap { attributes.merge!(...) }
  end

  def merge(...)
    dup.merge!(...)
  end
  alias_method :call, :merge

  ruby2_keywords def with(*names)
    configuration.lookup(*names).reduce(dup, :merge!)
  end

  ruby2_keywords def tag(*arguments, &block)
    if arguments.none? && block.nil?
      view_context.tag.with_options(attributes)
    else
      view_context.tag(*arguments, &block)
    end
  end

  def to_s
    attributes.to_s
  end

  def dup
    self.class.new(configuration, view_context, attributes.dup)
  end

  def method_missing(name, ...)
    receiver =
      if attributes.respond_to?(name)
        attributes
      elsif view_context.respond_to?(name)
        view_context.with_options(attributes)
      else
        super
      end

    receiver.public_send(name, ...)
  end

  def respond_to_missing?(name, include_private = false)
    [attributes, view_context].any? { |receiver| receiver.respond_to?(name, include_private) }
  end

  private

  attr_accessor :attributes, :configuration, :view_context
end
