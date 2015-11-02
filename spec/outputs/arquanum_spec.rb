# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/arquanum'

describe 'outputs/arquanum' do
  let(:config) { { 'key' => 'custom_key' } }

  let(:event) do
    LogStash::Event.new(
        'message' => 'SELECT *FROM products WHERE 1=1',
        'source' => 'productfoundation',
        'type' => 'nginx',
        '@timestamp' => LogStash::Timestamp.now)
  end

  context 'when initializing' do
    subject { LogStash::Outputs::Arquanum.new(config) }

    it 'should register' do
      expect { subject.register }.to_not raise_error
    end

    it 'should have default config values' do
      insist { subject.proto } == 'http'
      insist { subject.host } == 'logs.arquanum.com'
      insist { subject.tag } == 'logstash'
    end
  end

  context 'when outputting messages' do
    it 'should support field interpolation on key' do
      event['token'] = 'tokenssshhhhtoken'
      config['key'] = '%{token}'

      output = LogStash::Outputs::Arquanum.new(config)
      allow(output).to receive(:send_event).with('http://logs.arquanum.com/tokenssshhhhtoken/tag/logstash',
                                                 event.to_json)
      output.receive(event)
    end

    it 'should set the default tag to logstash' do
      output = LogStash::Outputs::Arquanum.new(config)
      allow(output).to receive(:send_event).with('http://logs.arquanum.com/tokenssshhhhtoken/tag/logstash',
                                                 event.to_json)
      output.receive(event)
    end

    it 'should support field interpolation for tag' do
      config['tag'] = '%{source}'
      output = LogStash::Outputs::Arquanum.new(config)
      allow(output).to receive(:send_event).with('http://logs.arquanum.com/tokenssshhhhtoken/tag/productfoundation',
                                                 event.to_json)
      output.receive(event)
    end

    it 'should default tag to logstash if interpolated field does not exist' do
      config['tag'] = '%{foobar}'
      output = LogStash::Outputs::Arquanum.new(config)
      allow(output).to receive(:send_event).with('http://logs.arquanum.com/tokenssshhhhtoken/tag/logstash',
                                                 event.to_json)
      output.receive(event)
    end
  end
end