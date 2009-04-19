class << Rails
  attr_accessor :plugins
end

Rails.plugins = initializer.loaded_plugins
