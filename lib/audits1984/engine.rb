require "console1984"
require "importmap-rails"
require "turbo-rails"
require "rinku"

module Audits1984
  class Engine < ::Rails::Engine
    isolate_namespace Audits1984

    config.audits1984 = ActiveSupport::OrderedOptions.new

    initializer "audits1984.config" do
      config.audits1984.each do |key, value|
        Audits1984.send("#{key}=", value)
      end
    end

    initializer "audits1984.session" do
      ActiveSupport.on_load(:console_1984_session) do
        include Audits1984::Session::Auditable, Audits1984::Session::Iterable
      end
    end

    initializer "audits1984.assets" do |app|
      app.config.assets.paths << root.join("app/assets/stylesheets")
      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.precompile << "audits1984_manifest.js"
    end

    initializer "audits1984.importmap", after: "importmap" do |app|
      Audits1984.importmap.draw(root.join("config/importmap.rb"))
      Audits1984.importmap.cache_sweeper(watches: root.join("app/javascript"))

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Audits1984.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end
