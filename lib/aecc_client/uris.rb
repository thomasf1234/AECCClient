require 'uri'
require 'net/http'

module AECCClient
  class Uris
    def initialize(host, port)
      @host = host
      @port = port
    end

    def healthcheck_uri
      uri("healthcheck")
    end

    def running_emulators_uri
      uri("database/running_emulators")
    end

    def avds_uri
      uri("avds")
    end

    def avd_start_uri
      uri("emulators/start")
    end

    def emulator_kill_uri
      uri("emulators/kill")
    end

    def package_uri(device_uuid)
      uri("emulators/#{device_uuid}/packages")
    end

    def reset_permissions_uri(device_uuid, package)
      uri("emulators/#{device_uuid}/packages/#{package}/permissions")
    end

    private
    def uri(end_point)
      URI.parse(File.join("http://#{@host}:#{@port}", end_point))
    end
  end
end

