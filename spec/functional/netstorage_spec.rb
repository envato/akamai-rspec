require 'spec_helper'

describe 'be_served_from_netstorage' do
  before(:each) do
    stub_headers('/netstorage', 'X-True-Cache-Key' => "S/=/12345/123456/1m/#{NETSTORAGE_DOMAIN}/1234/error.html")
    stub_headers('/', 'X-True-Cache-Key' => "/D/000/#{DOMAIN}/example")
  end

  it 'should succeed when netstorage domain is present' do
    expect(DOMAIN + '/netstorage').to be_served_from_netstorage
  end

  it 'should fail when netstorage domain is not present' do
    expect(DOMAIN + '/').to_not be_served_from_netstorage
  end
end
