require 'spec_helper'

module UrisSpec
  describe AECCClient::Uris do
    let(:uris) { AECCClient::Uris.new('127.0.0.1', '3000') }

    describe "#initialize" do
      it 'sets the host and port' do
        expect(uris.instance_variable_get(:@host)).to eq('127.0.0.1')
        expect(uris.instance_variable_get(:@port)).to eq('3000')
      end
    end

    describe '#healthcheck_uri' do
      it 'forms the correct uri' do
        uri = uris.healthcheck_uri

        expect(uri.host).to eq('127.0.0.1')
        expect(uri.port).to eq(3000)
        expect(uri.request_uri).to eq('/healthcheck')
      end
    end

    describe '#running_emulators_uri' do
      it 'forms the correct uri' do
        uri = uris.running_emulators_uri

        expect(uri.host).to eq('127.0.0.1')
        expect(uri.port).to eq(3000)
        expect(uri.request_uri).to eq('/database/running_emulators')
      end
    end

    describe '#avds_uri' do
      it 'forms the correct uri' do
        uri = uris.avds_uri

        expect(uri.host).to eq('127.0.0.1')
        expect(uri.port).to eq(3000)
        expect(uri.request_uri).to eq('/avds')
      end
    end

    describe '#avd_start_uri' do
      it 'forms the correct uri' do
        uri = uris.avd_start_uri

        expect(uri.host).to eq('127.0.0.1')
        expect(uri.port).to eq(3000)
        expect(uri.request_uri).to eq('/emulators/start')
      end
    end

    describe '#emulator_kill_uri' do
      it 'forms the correct uri' do
        uri = uris.emulator_kill_uri

        expect(uri.host).to eq('127.0.0.1')
        expect(uri.port).to eq(3000)
        expect(uri.request_uri).to eq('/emulators/kill')
      end
    end

    describe '#package_uri' do
      it 'forms the correct uri' do
        uri = uris.package_uri('e83c515-3af0-458a-a01a-129ad6cd74c0')

        expect(uri.host).to eq('127.0.0.1')
        expect(uri.port).to eq(3000)
        expect(uri.request_uri).to eq('/emulators/e83c515-3af0-458a-a01a-129ad6cd74c0/packages')
      end
    end

    describe '#reset_permissions_uri' do
      it 'forms the correct uri' do
        uri = uris.reset_permissions_uri('e83c515-3af0-458a-a01a-129ad6cd74c0', 'com.example.mypackage')

        expect(uri.host).to eq('127.0.0.1')
        expect(uri.port).to eq(3000)
        expect(uri.request_uri).to eq('/emulators/e83c515-3af0-458a-a01a-129ad6cd74c0/packages/com.example.mypackage/permissions')
      end
    end
  end
end
