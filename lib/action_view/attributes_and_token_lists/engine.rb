module ActionView
  module AttributesAndTokenLists
    class Engine < ::Rails::Engine
      initializer "action_view-attributes_and_token_lists.helpers" do
        require "action_view/attributes_and_token_lists/attributes"
        require "action_view/attributes_and_token_lists/attribute_merger"
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
          def with_attributes(options = {}, &block)
            attribute_merger = AttributeMerger.new self, self, options

            if block.nil?
              attribute_merger
            else
              block.arity.zero? ? attribute_merger.instance_eval(&block) : block.call(attribute_merger)
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
            Attributes.new(self, @view_context, attributes || {})
          end

          def with_attributes(options = {}, &block)
            case options
            when Attributes, AttributeMerger
              options.tag(&block)
            else
              attribute_merger = AttributeMerger.new @view_context, self, options

              if block.nil?
                attribute_merger
              else
                block.arity.zero? ? attribute_merger.instance_eval(&block) : block.call(attribute_merger)
              end
            end
          end

          alias_method :overridden_tag_string, :tag_string
          private :overridden_tag_string

          def tag_string(name, content = nil, escape: true, **options, &block)
            case content
            when Attributes, AttributeMerger
              overridden_tag_string(name, **content.to_hash.merge(options), escape: escape, &block)
            else
              overridden_tag_string(name, content, escape: escape, **options, &block)
            end
          end

          private

          alias_method :overridden_prefix_tag_option, :prefix_tag_option
          def prefix_tag_option(prefix, key, value, escape)
            value = value.to_s if value.is_a? TokenList

            overridden_prefix_tag_option(prefix, key, value, escape)
          end
        end
      end
    end
  end
end
