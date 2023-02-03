module ApplicationHelper
  include AttributesAndTokenLists::Helper

  html_attributes :ui do |ui|
    # ui.variant :button, class: "text-white p-4 focus:outline-none focus:ring" do |button|
    #   button.variant :style, {
    #     primary: {class: "bg-green-500"},
    #     secondary: {class: "bg-blue-500"},
    #     tertiary: {class: "bg-black"}
    #   }
    # end
  end
end
