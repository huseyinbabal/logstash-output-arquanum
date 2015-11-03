# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/arquanum'

describe "outputs/arquanum" do
  let(:config) {
    {
        'token' => 'very_secret_token_12345',
        'app_id' => 'app_id_12345'
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

=begin
  let(:client) do
    options = {
        :api_url => "1",
        :api_version => "2",
        :token => "3",
        :app_id => "4",
        :tag => "5",
        :proxy_host => "6",
        :proxy_port => "7",
        :proxy_user => "8",
        :proxy_password => "9"
    }
    LogStash::Outputs::Arquanum::ArquanumClient.new(options)
  end
=end

  around(:each) do |block|
    ao.register
    block.call()
    ao.close
  end

  context 'when initializing' do
    it 'should set default api_url if not set' do
      allow(ao).to receive(:send_event).with(event.to_json)
      ao.receive(event)
    end
  end
end