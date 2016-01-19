require 'spec_helper'
require 'rspec/expectations'
require 'openssl'

describe 'be_successful' do
  let(:prod_domain) { 'www.example.com.edgesuite.net' }
  let(:url) { 'example.com' }
  let(:origin) { stuff_url }
  before do
    AkamaiRSpec::Request.prod_domain = prod_domain
    stub_status(prod_domain, 'success', 200)
    stub_status(prod_domain, 'fail', 400)
  end

  it 'should pass when it gets a 200' do
    expect('example.com/success').to be_successful
  end

  it 'should fail when it gets 400' do
    expect { expect('example.com/fail').to be_successful }.to raise_error(RuntimeError)
  end
end

describe 'be_gzipped' do
  let(:prod_domain) { 'www.example.com.edgesuite.net' }
  before(:each) do
    AkamaiRSpec::Request.prod_domain = prod_domain
    zip = File.open('spec/fixtures/bar.gz', 'r')
    stub_headers(prod_domain, 'gzipped', { 'content-encoding' => 'gzip' }, zip.read)
    stub_headers(prod_domain, 'not_gzipped_lies', 'content-encoding' => 'gzip')
    stub_headers(prod_domain, 'gzipped_lies', { 'content-encoding' => 'something-else' }, zip.read)
    stub_headers(prod_domain, 'not_gzipped', 'content-encoding' => 'stuff')
    zip.close
  end

  it 'should pass when gzipped' do
    expect('example.com/gzipped').to be_gzipped
  end

  it 'should fail when not gzipped but header lies' do
    expect { expect('example.com/not_gzipped_lies').to be_gzipped }
      .to raise_error(Zlib::GzipFile::Error)
  end

  it 'should fail when gzipped but header lies' do
    expect { expect('example.com/gzipped_lies').to be_gzipped }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it 'should fail when not gzipped' do
    expect { expect('example.com/not_gzipped').to be_gzipped }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end

describe 'have_cookie' do
  let(:prod_domain) { 'www.example.com.edgesuite.net' }
  before(:each) do
    AkamaiRSpec::Request.prod_domain = prod_domain
    stub_headers(prod_domain, 'omnom', 'set-cookie' => 'cookie=yummy')
    stub_headers(prod_domain, 'no-cookie', {})
  end

  it 'should pass when cookie is set' do
    expect('example.com/omnom').to have_cookie('cookie')
  end

  it 'should fail when cookie is not set' do
    expect { expect('example.com/omnom').to have_cookie('wrong') }.to raise_error(RuntimeError)
  end

  it 'should fail when there are no cookies' do
    expect { expect('example.com/no-cookie').to have_cookie('wrong') }.to raise_error(RuntimeError)
  end
end

describe 'be_verifiably_secure' do
  it 'should succeed when it verifies correctly' do
    stub_request(:any, 'example.com').to_return(body: 'abc')
    expect('example.com').to be_verifiably_secure(false)
  end
end

describe 'be_forbidden' do
  before(:each) do
    stub_status('/success', 200)
    stub_status('/notfound', 404)
    stub_status('/forbidden', 403)
  end

  it 'should pass when it gets a 403' do
    expect(DOMAIN + '/forbidden').to be_forbidden
  end

  it 'should fail when it gets 404' do
    expect { expect(DOMAIN + '/notfound').to be_forbidden }.to raise_error(RuntimeError)
  end

  it 'should fail when it gets 200' do
    expect { expect(DOMAIN + '/success').to be_forbidden }.to raise_error(RuntimeError)
  end
end
