require 'helper'

describe Octospy::Parser do
  include_context :parser_params

  describe '#parse_watch_event' do
    let(:client) { double(Octokit::Client, web_endpoint: Octokit.web_endpoint) }
    let(:event_name) { 'watch_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_watch_event }

    it { expect(subject[:status]).to eq 'started repository' }
    it { expect(subject[:title]).to eq 'intridea/hashie' }
    it { expect(subject[:body]).to be_nil }
    it { expect(subject[:link]).to eq 'https://github.com//intridea/hashie' }
    it { expect(subject[:repository]).to be_nil }
  end

  describe '#parse_follow_event' do
    let(:client) { double(Octokit::Client, web_endpoint: Octokit.web_endpoint) }
    let(:event_name) { 'follow_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_follow_event }

    it { expect(subject[:status]).to eq 'followed' }
    it { expect(subject[:title]).to eq 'Watson1978 (Watson)' }
    it {
      expect(subject[:body]).to eq <<-BODY.pretty_heredoc
        \u000315repos\u000F: 66,
        \u000315followers\u000F: 101,
        \u000315following\u000F: 15,
        \u000315location\u000F: Japan,
        \u000315company\u000F: -,
        \u000315bio\u000F: -,
        \u000315blog\u000F: http://watson1978.github.io/
      BODY
    }
    it { expect(subject[:link]).to eq 'https://github.com//Watson1978' }
    it { expect(subject[:repository]).to be_nil }
    it { expect(subject[:notice]).to be_true }
  end
end
