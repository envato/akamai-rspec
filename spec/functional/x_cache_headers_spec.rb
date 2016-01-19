require 'spec_helper'

describe 'have_cp_code_set' do
  let(:prod_domain) { 'www.example.com.edgesuite.net' }
  before(:each) do
    AkamaiRSpec::Request.prod_domain = prod_domain
    stub_headers(prod_domain, 'correct', 'x-cache-key' => 'cp-code')
    stub_headers(prod_domain, 'correct-true-cache-key', 'x-true-cache-key' => 'cp-code')
    stub_headers(prod_domain, 'no-cp', {})
  end

  it 'should succeed when cp code set in x-cache-key' do
    expect('example.com/correct').to have_cp_code('cp-code')
  end

  it 'should succeed when cp code set in x-true-cache-key' do
    expect('example.com/correct-true-cache-key').to have_cp_code('cp-code')
  end

  it 'should fail when cp code is wrong' do
    expect { expect('example.com/correct').to have_cp_code('wrong') }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it 'should fail when both cache-key headers are not set' do
    expect { expect('example.com/no-cp').to have_cp_code('wrong') }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end

describe 'be_served_from_origin' do
  let(:prod_domain) { 'www.example.com.edgesuite.net' }

  before(:each) do
    AkamaiRSpec::Request.prod_domain = prod_domain
    x_cache = { 'x-cache-key' => 'A/B/1234/123456/000/originsite.example.com/' }
    x_true_cache = { 'x-true-cache-key' => 'A/B/1234/123456/000/originsite.example.com/' }
    stub_headers(prod_domain, 'correct', x_cache)
    stub_headers(prod_domain, 'correct-true', x_true_cache)
    stub_request(:any, "#{prod_domain}/redirect").to_return(
      body: 'abc', headers: x_cache,
      status: [300, 'message'])
  end

  it 'should succeed with 200 and correct origin in x-cache-key' do
    expect('example.com/correct').to be_served_from_origin('originsite.example.com')
  end

  it 'should succeed with 200 and correct origin in x-true-cache-key' do
    expect('example.com/correct-true').to be_served_from_origin('originsite.example.com')
  end

  it 'should fail on 300 and correct origin' do
    expect { expect('example.com/redirect').to be_served_from_origin('originsite.example.com') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it 'should fail on 200 and incorrect origin' do
    expect { expect('example.com/correct').to be_served_from_origin('someothersite.example.com') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it 'should fail on 200 and origin that only partially matches' do
    expect { expect('example.com/correct').to be_served_from_origin('site.example.com') }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end
