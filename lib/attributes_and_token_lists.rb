require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/action_view")
loader.setup

module AttributesAndTokenLists
end

if defined?(Rails::Engine)
  require "attributes_and_token_lists/engine"
end
