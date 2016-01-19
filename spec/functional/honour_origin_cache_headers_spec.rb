require 'spec_helper'

describe 'honour_origin_cache_headers' do

  let(:a_date_in_the_future) { 'Thu, 01 Dec 2015 07:00:00 GMT' }
  let(:a_date_in_the_future_plus_one) { 'Thu, 01 Dec 2015 07:01:00 GMT' }
  let(:stg_domain) { 'www.example.com.edgesuite-staging.net' }
  let(:prod_domain) { 'www.example.com.edgesuite.net' }
  let(:url) { 'example.com' }
  let(:stuff_url) { "#{url}/stuff"}
  let(:origin) { stuff_url }
  before do
    AkamaiRSpec::Request.prod_domain = prod_domain
    stub_headers(prod_domain, 'stuff', akamai_headers)
    stub_request(:any, origin).to_return(body: 'body', headers: origin_headers)
  end


  context 'headers are the same' do
    let(:origin_headers) { {'cache-control' => 'private, max-age=0, no-store', 'expires' => a_date_in_the_future} }
    let(:akamai_headers) { origin_headers }

    it 'succeeds' do
      expect(stuff_url).to honour_origin_cache_headers(stuff_url)
    end
  end

  context 'max age is greater' do
    let(:akamai_headers) { { 'cache-control' => 'public, max-age=120', 'expires' => a_date_in_the_future } }
    let(:origin_headers) { { 'cache-control' => 'public, max-age=60', 'expires' => a_date_in_the_future } }

    it 'fails' do
      expect {
        expect(stuff_url).to honour_origin_cache_headers(stuff_url)
      }.to raise_error(/Akamai sent a max-age greater than Origin/)
    end
  end

  context 'max age is lesser' do
    let(:akamai_headers) { { 'cache-control' => 'public, max-age=60', 'expires' => a_date_in_the_future } }
    let(:origin_headers) { { 'cache-control' => 'public, max-age=120', 'expires' => a_date_in_the_future } }

    it 'succeeds' do
      expect(stuff_url).to honour_origin_cache_headers(stuff_url)
    end
  end

  context 'the public/private cache-control directives differ' do
    let(:akamai_headers) { { 'cache-control' => 'private, max-age=0', 'expires' => a_date_in_the_future } }
    let(:origin_headers) { { 'cache-control' => 'public, max-age=0', 'expires' => a_date_in_the_future } }

    it 'fails' do
      expect {
        expect(stuff_url).to honour_origin_cache_headers(stuff_url)
      }.to raise_error(/Origin sent .* but Akamai did not/)
    end
  end

  context 'the store/caache directives differ' do
    let(:akamai_headers) { { 'cache-control' => 'public, max-age=0, no-store', 'expires' => a_date_in_the_future } }
    let(:origin_headers) { { 'cache-control' => 'public, max-age=0, no-cache', 'expires' => a_date_in_the_future } }

    it 'fails' do
      expect {
        expect(stuff_url).to honour_origin_cache_headers(stuff_url)
      }.to raise_error(/Origin sent .* but Akamai did not/)
    end
  end

  context 'the expires header differs' do
    let(:akamai_headers) { { 'cache-control' => 'public, max-age=0, no-store', 'expires' => a_date_in_the_future } }
    let(:origin_headers) { { 'cache-control' => 'public, max-age=0, no-store', 'expires' => a_date_in_the_future_plus_one } }

    it 'fails' do
      expect {
        expect(stuff_url).to honour_origin_cache_headers(stuff_url)
      }.to raise_error(/Origin sent .* but Akamai sent/)
    end
  end
end
