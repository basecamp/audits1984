require "console1984"
require 'rinku'

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

    initializer "audits1984.assets.precompile" do |app|
      app.config.assets.precompile << "audits1984_manifest.js"
    end
  end
end
