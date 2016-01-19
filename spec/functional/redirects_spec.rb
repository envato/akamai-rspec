require 'spec_helper'
require 'rspec/expectations'

describe 'be_permanently_redirected_to' do
  let(:url) { 'example.com/redirect' }
  before(:each) do
    stub_redirect('example.com', 301)
  end

  it 'should be successful on 301 to new' do
    expect(url).to be_permanently_redirected_to('/redirected')
  end

  it 'should fail on 301 to wrong location' do
    expect { expect(url).to be_permanently_redirected_to('/wrong') }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 300 to correct location' do
    stub_redirect('example.com', 300)
    expect { expect(url).to be_permanently_redirected_to('/redirected') }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 300 to wrong location' do
    stub_redirect('example.com', 300)
    expect { expect(url).to be_permanently_redirected_to('/wrong') }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 200' do
    stub_request(:any, url).to_return(body: 'abc')
    expect { expect(url).to be_permanently_redirected_to('/redirected') }
      .to raise_error(RuntimeError)
  end
end

describe 'be_temporarily_redirected_to' do
  let(:url) { 'example.com/redirect' }
  before(:each) do
    stub_redirect('example.com', 302)
  end

  it 'should be successful on 302 to new' do
    expect(url).to be_temporarily_redirected_to('/redirected')
  end

  it 'should fail on 302 to wrong location' do
    expect { expect(url).to be_temporarily_redirected_to('/wrong') }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 300 to correct location' do
    stub_redirect('example.com', 300)
    expect { expect(url).to be_temporarily_redirected_to('/redirected') }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 300 to wrong location' do
    stub_redirect('example.com', 300)
    expect { expect(url).to be_temporarily_redirected_to('/wrong') }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 200' do
    stub_request(:any, url).to_return(body: 'abc')
    expect { expect(url).to be_temporarily_redirected_to('/redirected') }
      .to raise_error(RuntimeError)
  end
end

describe 'be_temporarily_redirected_with_trailing_slash' do
  let(:url) { 'example.com/redirect' }
  before(:each) do
    stub_redirect('example.com', 302, 'example.com/redirect/')
    stub_request(:any, 'example.com/wrong').to_return(body: 'abc',
                                                    headers: { 'Location' => 'example.com/blerg/' },
                                                    status: [302, 'message'])
  end

  it 'should be successful on 302 to new' do
    expect(url).to be_temporarily_redirected_with_trailing_slash
  end

  it 'should fail on 302 to wrong location' do
    expect { expect('example.com/wrong').to be_temporarily_redirected_with_trailing_slash }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 302 without trailing slash' do
    stub_redirect('example.com', 302, '/redirected')
    expect { expect('example.com/redirect').to be_temporarily_redirected_with_trailing_slash }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 300 to correct location' do
    stub_redirect('example.com', 300)
    expect { expect('example.com/redirect').to be_temporarily_redirected_with_trailing_slash }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 300 to wrong location' do
    stub_redirect('example.com', 300)
    expect { expect('example.com/redirect').to be_temporarily_redirected_with_trailing_slash }
      .to raise_error(RuntimeError)
  end

  it 'should fail on 200' do
    stub_request(:any, 'example.com/redirect').to_return(body: 'abc')
    expect { expect('example.com/redirect').to be_temporarily_redirected_with_trailing_slash }
      .to raise_error(RuntimeError)
  end
end
