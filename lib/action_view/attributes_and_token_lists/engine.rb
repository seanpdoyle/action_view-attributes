module ActionView
  module AttributesAndTokenLists
    class Engine < ::Rails::Engine
      initializer "action_view-attributes_and_token_lists.helpers" do
        require "action_view/attributes_and_token_lists/attributes"
        require "action_view/attributes_and_token_lists/token_list"

        ActionView::Helpers::TagHelper.module_eval do
          def token_list(*tokens)
            TokenList.wrap(build_tag_values(*tokens))
          end
          alias_method :class_names, :token_list

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
          # To change the receiver from the view context, pass an object as the
          # first argument:
          #
          #   button = with_attributes class: "border rounded-sm p-4"
          #   button.link_to "I have a border", "/"
          #   #=> <a class="border rounded-sm p-4" href="/">I have a border</a>
          #
          #   primary = with_attributes button, class: "text-red-500 border-red-500"
          #   primary.link_to "I have a red border", "/"
          #   #=> <a class="border rounded-sm p-4 text-red-500 border-red-500" href="/">I have a red border</a>
          #
          #   secondary = with_attributes button, class: "text-blue-500 border-blue-500"
          #   secondary.link_to "I have a blue border", "/"
          #   #=> <a class="border rounded-sm p-4 text-blue-500 border-blue-500" href="/">I have a blue border</a>
          #
          def with_attributes(context = self, **options, &block)
            if block.nil?
              ActiveSupport::OptionMerger.new context, tag.attributes(options)
            else
              context.with_options tag.attributes(options), &block
            end
          end
        end

        ActionView::Helpers::TagHelper::TagBuilder.module_eval do
          # Transforms a Hash into HTML Attributes, ready to be interpolated into
          # ERB.
          #
          #   <input <%= tag.attributes(type: :text, aria: { label: "Search" }) %> >
          #   # => <input type="text" aria-label="Search">
          def attributes(attributes = {})
            Attributes.new(self, attributes || {})
          end

          private

          def prefix_tag_option(prefix, key, value, escape)
            key = "#{prefix}-#{key.to_s.dasherize}"

            value =
              case value
              when String, Symbol, BigDecimal
                value
              when TokenList
                value.to_a
              else
                value.to_json
              end

            tag_option(key, value, escape)
          end
        end
      end
    end
  end
end
