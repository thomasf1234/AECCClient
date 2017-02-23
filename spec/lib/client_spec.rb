require 'spec_helper'

module UrisSpec
  require 'socket'
  require 'timeout'

  class TestServer < Thread
    HOST = '127.0.0.1'
    PORT = 2000
    CRLF = "\r\n"
    TIMEOUT = 30

    attr_reader :server, :last_request, :exception

    def self.execute
      server = TCPServer.new(PORT)
      thread = new(server)
      yield
      thread.join
      thread.last_request
    end

    def initialize(server)
      super do
        begin
          socket = Timeout::timeout(TIMEOUT) do
            server.accept
          end

          # Read headers
          request_lines = []
          request_line = socket.gets
          request_lines << request_line
          http_method = request_line.match(/^\w+/).to_s
          loop do
            #read and readlines block so using gets
            request_line = socket.gets
            request_lines << request_line

            #reached the end of header information
            if request_line == CRLF
              break
            end
          end

          if http_method == 'POST'
            #read content_body
            content_length = request_lines.grep(/Content-Length/).first.match(/\d+/).to_s.to_i
            body = socket.read(content_length)
            request_lines << body
          end

          # Log the request to the console for debugging
          @last_request = TCPPacket.new(request_lines.join)
          # https://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html#sec6
          headers = []
          headers << "HTTP/1.1 200 OK"
          headers << "Connection: close"

          socket.puts(headers.join(CRLF))
          # Close the socket, terminating the connection
          socket.close
        rescue Exception => e
          @exception = e
          puts e
          raise e
        ensure
          if !server.closed?
            server.close
          end
        end
      end
    end

    class TCPPacket
      attr_reader :http_method, :end_point, :http_version, :headers, :raw_body
      def initialize(raw_packet)
        #split on first blank line
        header, body = raw_packet.split(CRLF + CRLF, 2)

        header_lines = header.lines.to_a
        http_header = header_lines.shift
        @http_method, @end_point, @http_version = http_header.split(' ').map(&:strip)

        @headers = {}
        header_lines.each do |line|
          key, value = line.split(':', 2).map(&:strip)
          @headers[key] = value
        end

        @raw_body = body
      end
    end
  end


  describe AECCClient::Client do
    let(:client) { AECCClient::Client.new(TestServer::HOST, TestServer::PORT) }

    describe "#healthcheck" do
      it 'sends correct request' do
        last_request = TestServer.execute { client.healthcheck }

        expect(last_request.http_method).to eq("GET")
        expect(last_request.end_point).to eq("/healthcheck")
        expect(last_request.http_version).to eq("HTTP/1.1")
        expect(last_request.headers['Host']).to eq("127.0.0.1:2000")
        expect(last_request.headers['Connection']).to eq("close")
        expect(last_request.headers['User-Agent']).to eq("Ruby")
        expect(last_request.raw_body).to eq("")
      end
    end

    describe "#avds" do
      it 'sends correct request' do
        last_request = TestServer.execute { client.avds }

        expect(last_request.http_method).to eq("GET")
        expect(last_request.end_point).to eq("/avds")
        expect(last_request.http_version).to eq("HTTP/1.1")
        expect(last_request.headers['Host']).to eq("127.0.0.1:2000")
        expect(last_request.headers['Connection']).to eq("close")
        expect(last_request.headers['User-Agent']).to eq("Ruby")
        expect(last_request.raw_body).to eq("")
      end
    end

    describe "#avd_start" do
      it 'sends correct request' do
        last_request = TestServer.execute { client.avd_start('Nexus_6_API_24') }

        expect(last_request.http_method).to eq("POST")
        expect(last_request.end_point).to eq("/emulators/start")
        expect(last_request.http_version).to eq("HTTP/1.1")
        expect(last_request.headers['Host']).to eq("127.0.0.1:2000")
        expect(last_request.headers['Content-Type']).to eq("application/x-www-form-urlencoded")
        expect(last_request.headers['Connection']).to eq("close")
        expect(last_request.headers['User-Agent']).to eq("Ruby")
        expect(last_request.headers['Content-Length']).to eq("23")
        expect(last_request.raw_body).to eq("avd_name=Nexus_6_API_24")
      end
    end

    describe "#emulator_kill" do
      it 'sends correct request' do
        last_request = TestServer.execute { client.emulator_kill('b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc') }

        expect(last_request.http_method).to eq("POST")
        expect(last_request.end_point).to eq("/emulators/kill")
        expect(last_request.http_version).to eq("HTTP/1.1")
        expect(last_request.headers['Host']).to eq("127.0.0.1:2000")
        expect(last_request.headers['Content-Type']).to eq("application/x-www-form-urlencoded")
        expect(last_request.headers['Connection']).to eq("close")
        expect(last_request.headers['User-Agent']).to eq("Ruby")
        expect(last_request.headers['Content-Length']).to eq("48")
        expect(last_request.raw_body).to eq("device_uuid=b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc")
      end
    end

    describe "#deploy_apk" do
      let(:file) { File.new('spec/samples/my_file.txt') }

      it 'sends correct request' do
        last_request = TestServer.execute { client.deploy_apk('b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc', file) }

        expect(last_request.http_method).to eq("POST")
        expect(last_request.end_point).to eq("/emulators/b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc/packages")
        expect(last_request.http_version).to eq("HTTP/1.1")
        expect(last_request.headers['Host']).to eq("127.0.0.1:2000")
        expect(last_request.headers['Content-Type']).to eq("multipart/form-data; boundary=a2fffb99f068eb2c")
        expect(last_request.headers['Connection']).to eq("close")
        expect(last_request.headers['User-Agent']).to eq("Ruby")
        expect(last_request.headers['Content-Length']).to eq("218")
        expect(last_request.raw_body).to eq("--a2fffb99f068eb2c\r\nContent-Disposition: form-data; name=\"data\"; filename=\"my_file.txt\"\r\nContent-Type: application/octet-stream\r\nContent-Length: 45\r\n\r\nFirst line of my file\n\nThird Line of my file\n\r\n--a2fffb99f068eb2c--")
      end
    end

    describe "#reset_permissions" do
      it 'sends correct request' do
        last_request = TestServer.execute { client.reset_permissions('b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc', 'com.example.package') }

        expect(last_request.http_method).to eq("POST")
        expect(last_request.end_point).to eq("/emulators/b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc/packages/com.example.package/permissions")
        expect(last_request.http_version).to eq("HTTP/1.1")
        expect(last_request.headers['Host']).to eq("127.0.0.1:2000")
        expect(last_request.headers['Content-Type']).to eq("application/x-www-form-urlencoded")
        expect(last_request.headers['Connection']).to eq("close")
        expect(last_request.headers['User-Agent']).to eq("Ruby")
        expect(last_request.headers['Content-Length']).to eq("12")
        expect(last_request.raw_body).to eq("action=reset")
      end
    end
  end
end
