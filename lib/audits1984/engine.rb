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
      if app.config.respond_to?(:assets)
        app.config.assets.precompile << "audits1984_manifest.js"
      else
        gem_asset_root = Audits1984::Engine.root.join("app/assets")
        tmp_asset_root = Rails.root.join("tmp/audits1984/assets")

        # Create audits1984 css and js files
        asset_files = [
          "javascripts/audits1984/application.js",
          "stylesheets/audits1984/bulma.min.css",
          "stylesheets/audits1984/application.css",
        ]

        asset_files.each do |file|
          unless (local_file = tmp_asset_root.join(file)).exist?
            local_file.dirname.mkpath
            local_file.write gem_asset_root.join(File.dirname(file)).children.map(&:read).join("\n\n")
          end
        end

        # Serve custom assets instead of audits1984's (that will 404 without the asset pipeline)
        Rails.application.config.middleware.use Rack::Static,
          urls: %w[/javascripts/audits1984 /stylesheets/audits1984 /images/audits1984],
          root: tmp_asset_root
      end
    end
  end
end
