require 'helper'

describe Octospy::Shortener do
  let(:url) { 'https://github.com/linyows/octospy' }

  describe '.shorten_by_github' do
    subject {
      VCR.use_cassette "git.io/#{url.escaping}" do
        described_class.shorten_by_github url
      end
    }

    it { expect(subject).to be_an_instance_of String }
    it { expect(subject).to eq 'http://git.io/Pd8gXg' }

    context 'when it is not in the url of github' do
      let(:url) { 'https://www.google.co.jp/search?q=octospy' }
      it { expect(subject).to eq url }
    end

    context 'when raise error' do
      it 'return url of argument' do
        expect(Faraday).to receive(:new).and_raise Faraday::Error
        expect(described_class.shorten_by_github url).to eq url
      end
    end
  end

  describe '.shorten_by_google' do
    subject {
      VCR.use_cassette "googleapis.com/urlshortener/#{url.escaping}" do
        described_class.shorten_by_google url
      end
    }

    it { expect(subject).to be_an_instance_of String }
    it { expect(subject).to eq 'http://goo.gl/8vrLj' }

    context 'when raise error' do
      it 'return url of argument' do
        expect(Faraday).to receive(:new).and_raise Faraday::Error
        expect(described_class.shorten_by_google url).to eq url
      end
    end
  end
end
