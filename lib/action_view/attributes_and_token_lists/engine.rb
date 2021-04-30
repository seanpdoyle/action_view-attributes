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
