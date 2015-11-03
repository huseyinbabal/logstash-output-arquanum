module LogStash::Outputs::Arquanum
  class ArquanumClient
    include HTTParty

    def initialize(options = {})
      @logger = options[:logger]
      @options = options
    end

    def create_payload(message)
      {
          :app_id => @options[:app_id],
          :tag => @options[:tag],
          :message => message
      }
    end

    def create_headers
      {
        :'Authorization' => "Bearer #{@options[:token]}",
        :'X-Api-Version' => @options[:api_version]
      }
    end

    def send(message)
      api_url = options[:api_url]
      http_proxy options[:proxy_host], options[:proxy_port], options[:proxy_user], options[:proxy_pass]
      HTTParty.post api_url, :query => create_payload(:message => message), :headers => create_headers
    end
  end
end