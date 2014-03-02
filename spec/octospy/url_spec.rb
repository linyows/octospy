require 'helper'

describe Octospy::Url do
  let(:url) { 'https://github.com/linyows/octospy' }

  describe '.shorten_by_github', :vcr do
    subject { described_class.shorten_by_github url }

    it { expect(subject).to be_an_instance_of String }
    it { expect(subject).to eq 'http://git.io/Pd8gXg' }
  end

  describe '.shorten_by_google', :vcr do
    subject { described_class.shorten_by_google url }

    it { expect(subject).to be_an_instance_of String }
    it { expect(subject).to eq 'http://goo.gl/8vrLj' }
  end
end
