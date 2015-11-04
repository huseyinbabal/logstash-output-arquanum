# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/arquanum'

describe 'outputs/arquanum' do
  let(:config) {
    {
        'app_id' => 'app_id_12345',
        'token' => 'very_secret_token_12345'
    }
  }

  let(:event) do
    LogStash::Event.new(
        'message' => 'this is log message',
        'source' => 'product foundation',
        'type' => 'access',
        '@timestamp' => LogStash::Timestamp.now)
  end

  let(:ao) do
    LogStash::Outputs::Arquanum.new(config)
  end

  around(:each) do |block|
    ao.register
    block.call()
    ao.close
  end

  context 'when initializing' do
    it 'should register' do
      expect { ao.register }.to_not raise_error
    end

    it 'should set default api_url if not set' do
      expect(ao.api_url).to eq('https://api.arquanum.com/logs')
    end

    it 'should set default api_version if not set' do
      expect(ao.api_version).to eq('1.0')
    end

    it 'should set default tag if not set' do
      expect(ao.tag).to eq('logstash')
    end

    it 'should set app_id correctly' do
      expect(ao.app_id).to eq('app_id_12345')
    end

    it 'should set token correctly' do
      expect(ao.token).to eq('very_secret_token_12345')
    end
  end

  context 'when sending messages' do
    it 'should send event' do
      allow(ao).to receive(:send_event).with(event.to_json)
      ao.receive(event)
    end
  end
end