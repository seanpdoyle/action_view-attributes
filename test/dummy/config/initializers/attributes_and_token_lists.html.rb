ActiveSupport.on_load :attributes_and_token_lists do
  builder :initializer do
    base :button, tag_name: :button, class: "text-white p-4 focus:outline-none focus:ring" do
      variant :primary, class: "bg-green-500"
      variant :secondary, class: "bg-blue-500"
      variant :tertiary, class: "bg-black"
    end
  end
end
