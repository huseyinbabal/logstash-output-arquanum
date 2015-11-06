# encoding: utf-8
require 'logstash/outputs/base'
require 'logstash/namespace'
require 'httparty'

# Arquanum Logstash Plugin lets you to send your logs to arquanum log
# analyzing system to perform deep machine learning testing to
# detect possible security attacks.

class LogStash::Outputs::Arquanum < LogStash::Outputs::Base
  include HTTParty

  config_name "arquanum"

  # api_url is used for sending log data to Arquanum.
  # This url is configurable according to region of your
  # application source. This will be "logs.arquanum.com" by default
  config :api_url, :validate => :string, :default => "https://api.arquanum.com/logs"

  # There may be 2 versions of the api at a time. You can use specific
  # version according to your needs. If we release new features, you can
  # test it by switching your api_version
  config :api_version, :validate => :string, :default => "1.0"

  # app_id is for grouping your log data on Arqunum
  # according to your app_id. Before starting sending log data,
  # you need to create application on Arquanum. For example, you can
  # create "test" application for testing your integration
  # By doing this, you can isolate your logs from different
  # environments. Some application examples: "Dev Logs",
  # "QA Logs", "Prod Logs", etc...
  config :app_id, :validate => :string

  # If you have Arquanum account, you can grab your token
  # from Arquanum App Dashboard http://admin.arquanum.com/apps.
  # This token will be used for authorizing your requests
  config :token, :validate => :string, :required => true

  # Loggly Tag
  # Tag helps you to find your logs in the Loggly dashboard easily
  # You can make a search in Loggly using tag as "tag:logstash-contrib"
  # or the tag set by you in the config file.
  config :tag, :validate => :string, :default => "logstash"

  # Proxy Host
  config :proxy_host, :validate => :string

  # Proxy Port
  config :proxy_port, :validate => :number

  # Proxy Username
  config :proxy_user, :validate => :string

  # Proxy Password
  config :proxy_password, :validate => :password, :default => ""

  public
  def register
    self.class.http_proxy @proxy_host, @proxy_port, @proxy_user, @proxy_pass
  end

  public
  def receive(event)
    if event == LogStash::SHUTDOWN
      finished
      return
    end

    # Send event
    send_event(format_message(event))
  end # def receive

  public
  def format_message(event)
    event.to_json
  end

  def send_event(message)
    begin
      response = send(message)
      parsed_response = response.parsed_response
      case parsed_response['success'].to_s
        when 'true'
          @logger.info("Log entry sent to Arquanum successfully.")
        when 'false'
          @logger.warn("Error occured while sending log entry to Arquanum: ", :error => parsed_response['result'])
      end
    rescue StandardError => err
      @logger.warn("Couldn't connect to Arquanum: ", :error => err)
    end
  end # def send_event

  def send(message)

    @payload = {
        :app_id => @app_id,
        :tag => @tag,
        :message => message
    }

    @headers = {
        'Authorization' => "Bearer #{@token}",
        'X-Api-Version' => @api_version,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
    }
    @logger.info("Arquanum Request Payload: ", :api_url => @api_url, :body => @payload, :headers => @headers)
    self.class.post @api_url, :body => JSON.dump(@payload), :headers => @headers
  end

end # class LogStash::Outputs::Arquanum
