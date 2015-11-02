module LogStash::Outputs::Arquanum
    class ArquanumClient
        include HTTParty

        attr_reader :client

        def initialize(options = {})
            @logger = options[:logger]
            @options = options
            @client = create_client(@options)
        end

        private
        def send(options)
            api_url = options[:api_url]
            http_proxy options[:proxy_host], options[:proxy_port], options[:proxy_user], options[:proxy_pass]
            HTTParty.post api_url, :query =>
        end
    end
end