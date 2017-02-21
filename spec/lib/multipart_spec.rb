require 'spec_helper'

module MultipartSpec
  describe AECCClient::Multipart do
    let(:file) { File.new('spec/samples/my_file.txt') }
    let(:expected_header) { {"Content-Type" => "multipart/form-data; boundary=a2fffb99f068eb2c"} }
    let(:expected_body) do
      "--a2fffb99f068eb2c\r\nContent-Disposition: form-data; name=\"data\"; filename=\"my_file.txt\"\r\nContent-Type: application/octet-stream\r\nContent-Length: 45\r\n\r\nFirst line of my file\n\nThird Line of my file\n\r\n--a2fffb99f068eb2c--"
    end

    it 'forms the correct header and body' do
      multipart = AECCClient::Multipart.new(file, 'application/octet-stream')

      expect(multipart.header).to eq(expected_header)
      expect(multipart.body).to eq(expected_body)
    end
  end
end
