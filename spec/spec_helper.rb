require 'rspec'
require 'webmock/rspec'
require 'akamai_rspec'

def stub_headers(url, headers, body = 'abc')
  stub_request(:any, url).to_return(
    body: body, headers: headers)
end

def stub_status(url, status)
  stub_request(:any, url).to_return(
    body: 'abc', status: [status, 'message'])
end

def stub_redirect(status, location = '/redirected')
  stub_request(:any, '/redirect').to_return(
    body: 'abc', headers: { 'Location' => location }, status: [status, 'message'])
end
