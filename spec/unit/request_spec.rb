require 'spec_helper'
require 'rspec/expectations'

describe AkamaiRSpec::Request do
  let(:stg_domain) { 'www.example.com.edgesuite-staging.net' }
  let(:prod_domain) { 'www.example.com.edgesuite.net' }
  let(:url) { 'example.com' }
  let(:network) { 'prod' }
  before do
    AkamaiRSpec::Request.stg_domain = stg_domain
    AkamaiRSpec::Request.prod_domain = prod_domain
    AkamaiRSpec::Request.network = network
    stub_status(prod_domain, '', 200)
    stub_status(stg_domain, '', 200)
  end

  subject { described_class.get(url) }

  describe '#get' do
    context 'prod domain' do
      it 'queries the right domain' do
        expect(Net::HTTP).to receive(:start).with(prod_domain, anything)
        subject
      end
    end

    context 'staging domain' do
      let(:network) { 'staging' }
      it 'quereis the right domain' do
        expect(Net::HTTP).to receive(:start).with(stg_domain, anything)
        subject
      end
    end
  end

  describe '#responsify' do
    let(:url) { 'nonexistantdomain' }
    before do
      stub_request(:any, url).to_return(
        body: 'abc', status: [500, 'message'])
    end
    it 'should not raise an exception when a RestClient exception is raised' do
      expect { RestClient::Request.responsify(url) }.to_not raise_error
    end
  end
end
