require 'rspec'

RSpec::Matchers.define :be_served_from_netstorage do
  match do |url|
    served_from_netstorage?(url)
  end
end

def served_from_netstorage?(url)
  response = AkamaiRSpec::Request.get_with_debug_headers(url)

  if response.headers[:x_true_cache_key].include?(NETSTORAGE_DOMAIN)
    true
  else
    false
  end
end
