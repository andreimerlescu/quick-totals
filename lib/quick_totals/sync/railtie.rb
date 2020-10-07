module QuickTotals
  module Sync
    class Railtie < Rails::Railtie
      initializer "concerns.autoload", before: :set_autoload_paths do |app|
        models_path = File.join File.dirname(__FILE__), "models"
        app.config.autoload_paths += [models_path]
      end #/block
    end #/class
  end #/module
end #/module