require 'uri'
require 'net/http'

module AECCClient
  class Client
    def initialize(host, port)
      @uri = AECCClient::Uris.new(host, port)
    end

    def healthcheck
      get(@uri.healthcheck_uri)
    end

    def avds
      get(@uri.avds_uri)
    end

    def avd_start(avd_name)
      post(@uri.avd_start_uri, {'avd_name' => avd_name})
    end

    def emulator_kill(device_uuid)
      post(@uri.emulator_kill_uri, {"device_uuid" => device_uuid})
    end

    def deploy_apk(device_uuid, file)
      uri =  @uri.package_uri(device_uuid)
      multipart = AECCClient::Multipart.new(file, 'application/octet-stream')
      post_custom(uri, multipart.header, multipart.body)
    end

    def reset_permissions(device_uuid, package)
      post(@uri.reset_permissions_uri(device_uuid, package), {'action' => 'reset'})
    end

    private
    def get(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response
    end

    def post(uri, params)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(params)
      response = http.request(request)
      response
    end

    def post_custom(uri, header, body)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body
      response = http.request(request)
      response
    end

    def uri(end_point)
      URI.parse(File.join("http://#{host}:#{port}", end_point))
    end
  end
end


