require 'spec_helper'

describe 'caching matchers' do
  let(:domain) { 'www.example.com.edgesuite.net' }
  let(:url) { 'example.com' }
  let(:cacheable_url) { "#{url}/cacheable" }
  let(:not_cacheable_url) { "#{url}/not_cacheable" }
  let(:real_cacheable_url) { "#{domain}/cacheable"}
  let(:real_not_cacheable_url) { "#{domain}/not_cacheable"}
  before(:each) do
    AkamaiRSpec::Request.prod_domain = domain
    stub_headers(domain, "cacheable", 'X-Check-Cacheable' => 'YES')
    stub_headers(domain, "not_cacheable", 'X-Check-Cacheable' => 'NO')
  end
  describe 'be_cacheable' do

    it 'should succeed when cacheable' do
      expect(cacheable_url).to be_cacheable
    end

    it 'should fail when not cacheable' do
      expect { expect(not_cacheable_url).to be_cacheable }.to raise_error(RuntimeError)
    end
  end

  describe 'have_no_cache_set' do
    it 'should succeed when not cacheable' do
      expect(cacheable_url).to have_no_cache_set
    end

    it 'should fail when cacheable' do
      expect { expect(not_cacheable_url).to have_no_cache_set }.to raise_error(RuntimeError)
    end
  end

  describe 'not_be_cached' do
    let(:cacheable_but_miss) { "#{url}/cacheable_but_miss" }
    let(:cacheable_and_cached) { "#{url}/cacheable_and_cached" }
    let(:not_cacheable_but_cached) { "#{url}/not_cacheable_but_cached" }
    before(:each) do
      stub_headers(domain, "cacheable_but_miss", 'X-Check-Cacheable' => 'YES', 'X-Cache' => 'TCP_MISS')
      stub_headers(domain, "not_cacheable_url", 'X-Check-Cacheable' => 'NO', 'X-Cache' => 'TCP_MISS')
      stub_headers(domain, "cacheable_and_cached", 'X-Check-Cacheable' => 'YES', 'X-Cache' => 'TCP_HIT')
      stub_headers(domain, "not_cacheable_but_cached", 'X-Check-Cacheable' => 'NO', 'X-Cache' => 'TCP_HIT')
    end

    it 'should succeed when not cacheable' do
      expect(not_cacheable_url).to not_be_cached
    end

    it 'should fail when cacheable but missed' do
      expect { expect(cacheable_but_miss).to not_be_cached }.to raise_error(RuntimeError)
    end

    it 'should fail when supposedly not cacheable but cached anyway' do
      expect { expect(not_cacheable_but_cached).to not_be_cached }
        .to raise_error(RuntimeError)
    end

    it 'should fail when cacheable and cached' do
      expect { expect(cacheable_and_cached).to not_be_cached }
        .to raise_error(RuntimeError)
    end
  end

  describe 'be_tier_distributed' do
    before(:each) do
      cacheable_uri = Addressable::Template.new url + '/cacheable?{random}'
      stub_request(:any, cacheable_uri).to_return(
        body: 'abc', headers: { 'X_Cache_Remote' => 'TCP_MISS' })
      not_cacheable_uri = Addressable::Template.new url + '/not_cacheable?{random}'
      stub_request(:any, not_cacheable_uri).to_return(
        body: 'abc', headers: { 'Cache-control' => 'no-cache' })
    end

    it 'should succeed when it is remote cached' do
      expect(cacheable_url).to be_tier_distributed
    end

    it 'should fail when not remotely cached' do
      expect { expect(not_cacheable_url).to be_tier_distributed }.to raise_error(RuntimeError)
    end
  end
end
