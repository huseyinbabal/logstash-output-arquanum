# encoding: utf-8
require 'logstash/outputs/base'
require 'logstash/namespace'

# Arquanum Logstash Plugin lets you to send your logs to arquanum log
# analyzing system to perform deep machine learning testing to
# detect possible security attacks.

class LogStash::Outputs::Arquanum < LogStash::Outputs::Base

  attr_reader :client

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
    @client = LogStash::Outputs::Arquanum::ArquanumClient.new(:options => create_options)
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

  private
  def create_options
    {
        :api_url => @config[:api_url],
        :api_version => @config[:api_version],
        :token => @config[:token],
        :app_id => @config[:app_id],
        :tag => @config[:tag],
        :proxy_host => @config[:proxy_host],
        :proxy_port => @config[:proxy_port],
        :proxy_user => @config[:proxy_user],
        :proxy_password => @config[:proxy_password]
    }
  end

  private
  def send_event(message)
    response = @client::send(:message => message)
    case response.code
      when 200
        @logger.info("Log entry sent to Arquanum successfully.")
      when 500...600
        @logger.warn("Error occured while sending log entry to Arquanum: ", :error => response.error)
    end
  end # def send_event

end # class LogStash::Outputs::Arquanum
