# http://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
module AECCClient
  class Multipart
    BOUNDARY = 'a2fffb99f068eb2c'
    CRLF = "\r\n"

    attr_reader :header, :body

    def initialize(file, content_type)
      @header = {"Content-Type" => "multipart/form-data; boundary=#{BOUNDARY}"}

      body = []
      body << encapsulation_boundary
      body << "Content-Disposition: form-data; name=\"data\"; filename=\"#{File.basename(file)}\""
      body << "Content-Type: #{content_type}"
      body << "Content-Length: #{file.size}" + CRLF
      body << File.read(file)
      body << closing_boundary
      @body = body.join(CRLF)
    end

    private
    def encapsulation_boundary
      "--#{BOUNDARY}"
    end

    def closing_boundary
      "#{encapsulation_boundary}--"
    end
  end
end

