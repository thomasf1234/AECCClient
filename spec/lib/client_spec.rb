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
          @last_request = request_lines.join
          # https://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html#sec6
          headers = []
          headers << "HTTP/1.1 200 OK"
          headers << "Connection: close"

          socket.puts(headers.join(CRLF))
          # Close the socket, terminating the connection
          socket.close
        rescue Exception => e
          @exception = e
          raise e
        ensure
          if !server.closed?
            server.close
          end
        end
      end
    end
  end


  describe AECCClient::Client do
    let(:client) { AECCClient::Client.new(TestServer::HOST, TestServer::PORT) }

    describe "#healthcheck" do
      let(:expected_last_request) do
        "GET /healthcheck HTTP/1.1\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: 127.0.0.1:2000\r\n\r\n"
      end

      it 'sends correct request' do
        last_request = TestServer.execute { client.healthcheck }
        expect(last_request).to eq(expected_last_request)
      end
    end

    describe "#avds" do
      let(:expected_last_request) do
        "GET /avds HTTP/1.1\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: 127.0.0.1:2000\r\n\r\n"
      end

      it 'sends correct request' do
        last_request = TestServer.execute { client.avds }
        expect(last_request).to eq(expected_last_request)
      end
    end

    describe "#avd_start" do
      let(:expected_last_request) do
        "POST /emulators/start HTTP/1.1\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nContent-Type: application/x-www-form-urlencoded\r\nConnection: close\r\nHost: 127.0.0.1:2000\r\nContent-Length: 23\r\n\r\navd_name=Nexus_6_API_24"
      end

      it 'sends correct request' do
        last_request = TestServer.execute { client.avd_start('Nexus_6_API_24') }
        expect(last_request).to eq(expected_last_request)
      end
    end

    describe "#emulator_kill" do
      let(:expected_last_request) do
        "POST /emulators/kill HTTP/1.1\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nContent-Type: application/x-www-form-urlencoded\r\nConnection: close\r\nHost: 127.0.0.1:2000\r\nContent-Length: 48\r\n\r\ndevice_uuid=b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc"
      end

      it 'sends correct request' do
        last_request = TestServer.execute { client.emulator_kill('b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc') }
        expect(last_request).to eq(expected_last_request)
      end
    end

    describe "#deploy_apk" do
      let(:expected_last_request) do
        "POST /emulators/b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc/packages HTTP/1.1\r\nContent-Type: multipart/form-data; boundary=a2fffb99f068eb2c\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: 127.0.0.1:2000\r\nContent-Length: 218\r\n\r\n--a2fffb99f068eb2c\r\nContent-Disposition: form-data; name=\"data\"; filename=\"my_file.txt\"\r\nContent-Type: application/octet-stream\r\nContent-Length: 45\r\n\r\nFirst line of my file\n\nThird Line of my file\n\r\n--a2fffb99f068eb2c--"
      end

      let(:file) { File.new('spec/samples/my_file.txt') }

      it 'sends correct request' do
        last_request = TestServer.execute { client.deploy_apk('b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc', file) }
        expect(last_request).to eq(expected_last_request)
      end
    end

    describe "#reset_permissions" do
      let(:expected_last_request) do
        "POST /emulators/b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc/packages/com.example.package/permissions HTTP/1.1\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nContent-Type: application/x-www-form-urlencoded\r\nConnection: close\r\nHost: 127.0.0.1:2000\r\nContent-Length: 12\r\n\r\naction=reset"
      end

      it 'sends correct request' do
        last_request = TestServer.execute { client.reset_permissions('b45cfb29-0ec7-4682-93a0-7f6cf2c7d5cc', 'com.example.package') }
        expect(last_request).to eq(expected_last_request)
      end
    end
  end
end
