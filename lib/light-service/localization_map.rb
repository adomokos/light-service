require 'singleton'

module LightService
  class LocalizationMap < Hash
    include ::Singleton
  end
end
