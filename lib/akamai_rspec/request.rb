require 'rest-client'
require 'delegate'

module AkamaiRSpec
  class Request
    extend Forwardable

    def self.stg_domain=(domain)
      @@akamai_stg_domain = domain
    end

    def self.prod_domain=(domain)
      @@akamai_prod_domain = domain
    end

    def self.network=(env)
      @@env = env
    end

    def self.get(url)
      new.get(url)
    end

    def self.get_with_debug_headers(url)
      new.get(url, AkamaiHeaders.akamai_debug_headers)
    end

    def initialize
      @@env ||= 'prod'

      @domain = case @@env.downcase
                when 'staging'
                  @@akamai_stg_domain
                else
                  @@akamai_prod_domain
                end

      @rest_client = RestClient::Request.new(method: :get,
                                              url: 'fakeurl.com',
                                              verify_ssl: false)
    end

    delegate [:parse_url_with_auth, :stringify_headers] => :@rest_client

    def get(url, headers = {})
      uri = parse_url_with_auth(url)

      req = build_request(uri, stringify_headers(headers))

      req['Host'] = uri.hostname
      uri.hostname = @domain

      @response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req, nil) { |http_response| http_response }
      end

      self
    end

    def headers
      headers = Hash[@response.to_hash.map{ |k, v| [k.gsub(/-/,'_').downcase.to_sym, v] }]
      headers.map do |k, v|
        if v.is_a?(Array) && v.size == 1
          []
        end
      end
    end

    def build_request(uri, headers)
      req = Net::HTTP::Get.new(uri)
      headers.each { |key, value| req.send(:[]=, key, value) }

      req
    end
  end
end
