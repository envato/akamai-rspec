require 'rspec'
require 'webmock/rspec'
require 'akamai_rspec'

def stub_headers(domain, url, headers, body = 'abc')
  stub_request(:any, "#{domain}/#{url}").to_return(
    body: body, headers: headers, status: [200, 'message'])
end

def stub_status(domain, url, status)
  stub_request(:any, "#{domain}/#{url}").to_return(
    body: 'abc', status: [status, 'message'])
end

def stub_redirect(status, location = '/redirected')
  stub_request(:any, DOMAIN + '/redirect').to_return(
    body: 'abc', headers: { 'Location' => DOMAIN + location }, status: [status, 'message'])
end
