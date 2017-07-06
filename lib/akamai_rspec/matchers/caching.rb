require 'rspec'
require 'securerandom'

RSpec::Matchers.define :be_cacheable do
  match do |url|
    @error = ""
    response = AkamaiRSpec::Request.get_with_debug_headers url
    x_check_cacheable(response, 'YES') && response.code == 200
  end

  failure_message do
    @error
  end
end

module RSpec::Matchers
  alias_method :be_cachable, :be_cacheable
end

RSpec::Matchers.define :have_no_cache_set do
  match do |url|
    response = AkamaiRSpec::Request.get url
    cache_control = response.headers[:cache_control]
    cache_control == 'no-cache'
  end

  failure_message do
    "Cache-Control has been set to '#{response.headers[:cache_control]}' expected 'no-cache'"
  end

  failure_message_when_negated do
    "Cache-Control has been set to 'no-cache'"
  end
end

RSpec::Matchers.define :not_be_cached do

  match do |url|
    @error = ""
    response = AkamaiRSpec::Request.get_with_debug_headers url
    not_cacheable = x_check_cacheable(response, 'NO')
    response = AkamaiRSpec::Request.get_with_debug_headers url  # again to prevent spurious cache miss

    not_cached = response.headers[:x_cache] =~ /TCP(\w+)?_MISS/
    if not_cached && not_cacheable
      true
    else
      msg = "x_cache header does not indicate an origin hit: '#{response.headers[:x_cache]}'"
      @error.length > 0 ? @error += "\n#{msg}" : @error = msg
      false
    end
  end

  failure_message do
    @error
  end
end

RSpec::Matchers.define :be_tier_distributed do
  match do |url|
    response = AkamaiRSpec::Request.get_cache_miss(url)
    tiered = !response.headers[:x_cache_remote].nil?
    response.code == 200 && tiered
  end

  failure_message do
    'No X-Cache-Remote header in response'
  end

  failure_message_when_negated do
    'X-Cache-Remote header in response'
  end
end

def x_check_cacheable(response, should_be_cacheable)
  x_check_cacheable = response.headers[:x_check_cacheable]
  if x_check_cacheable.nil?
    @error = 'No X-Check-Cacheable header?'
    false
  elsif (x_check_cacheable != should_be_cacheable)
    @error = "X-Check-Cacheable header is: #{x_check_cacheable} expected #{should_be_cacheable}"
    false
  else
    true
  end
end
