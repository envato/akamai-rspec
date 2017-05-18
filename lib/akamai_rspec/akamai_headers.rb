module AkamaiHeaders
  def self.akamai_debug_headers
    {
      pragma: %w(
        akamai-x-cache-on
        akamai-x-cache-remote-on
        akamai-x-check-cacheable
        akamai-x-feo-trace
        akamai-x-get-cache-key
        akamai-x-get-client-ip
        akamai-x-get-extracted-values
        akamai-x-get-nonces
        akamai-x-get-request-id
        akamai-x-get-ssl-client-session-id
        akamai-x-get-true-cache-key
        akamai-x-serial-no
      ).join(', ')
    }
  end
end
