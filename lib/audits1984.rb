require "audits1984/version"
require "audits1984/engine"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Audits1984
  mattr_accessor :auditor_class, default: "::User"
  mattr_accessor :auditor_name_attribute, default: :name
  mattr_accessor :base_controller_class, default: "::ApplicationController"
end
