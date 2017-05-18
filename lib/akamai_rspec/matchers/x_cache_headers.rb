require 'rspec'

module AkamaiRSpec
  module Helpers
    X_CACHE_HEADERS = [:x_true_cache_key, :x_cache_key]

    X_CACHE_KEY_PATTERN = Regexp.new(
      %r{(?<secure>\w)/(?<typecode>\w)/(?<serial>\d+)/(?<cpcode>\d+)/(?<ttl>[^/]+)/(?<fwd_path>[^\?]+)(?<query_string>.*)}
    )

    def x_cache_headers
      X_CACHE_HEADERS
    end

    def cp_code(headers)
      return nil unless headers.has_key?(:x_cache_key)
      headers[:x_cache_key].match(X_CACHE_KEY_PATTERN)['cpcode']&.to_i
    end
  end
end

RSpec::Matchers.define :be_served_from_origin do |contents|
  include AkamaiRSpec::Helpers
  match do |url|
    response = AkamaiRSpec::Request.get url
    response.headers.any? { |key, value| x_cache_headers.include?(key) && value =~ /\/#{contents}\// } && \
      response.code == 200
  end
end

#
# This matcher uses thread-local storage to save the `actual` value
#   for use in the failure message.
RSpec::Matchers.define :have_cp_code do |expected|
  include AkamaiRSpec::Helpers
  match do |url|
    response = AkamaiRSpec::Request.get url, AkamaiHeaders.akamai_debug_headers
    Thread.current["cpcode_for_#{url}"] = actual = cp_code(response.headers)
    actual == expected
  end
  failure_message do |url|
    actual_cpcode = Thread.current["cpcode_for_#{url}"]
    if actual_cpcode.nil?
      "expected cpcode #{expected} for #{url} but no cpcode was found"
    else
      "expected cpcode #{expected} for #{url} but got #{actual_cpcode}"
    end
  end
end
