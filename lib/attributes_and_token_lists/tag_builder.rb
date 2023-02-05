class AttributesAndTokenLists::TagBuilder
  delegate_missing_to :@tag_with_options

  def initialize(tag, tag_name, attributes)
    @tag = tag
    @tag_name = tag_name
    @attributes = attributes
    @tag_with_options = tag.with_options(attributes)
  end

  def to_s
    @tag.public_send(@tag_name, nil, **@attributes)
  end
end
