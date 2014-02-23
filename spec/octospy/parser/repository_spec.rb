require 'helper'

describe Octospy::Parser do
  include_context :parser_params

  describe '#parse_push_event' do
    let(:shorten_url) { 'http://git.io/Qq_ufw' }
    let(:client) {
      client = double(Octokit::Client)
      client.stub_chain(:commit, :author, :login).and_return('mockingname')
      client.stub(:web_endpoint).and_return(Octokit.web_endpoint)
      String.any_instance.stub(:shorten).and_return shorten_url
      client
    }
    let(:event_name) { 'push_event' }

    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_push_event }

    it { expect(subject[:status]).to eq 'pushed to master' }
    it { expect(subject[:title]).to be_nil }
    it { expect(subject[:body]).to be_an_instance_of Array }
    it {
      expect(subject[:body][0]).to eq <<-BODY.pretty_heredoc
        \u000315mockingname\u000F:
        update send and connect - \u000302#{shorten_url}\u000F
      BODY
    }
    it { expect(subject[:body]).to have(2).items }
    it { expect(subject[:link]).to eq 'https://github.com//visionmedia/express' }
  end

  describe '#parse_create_event' do
    let(:client) { double(Octokit::Client, web_endpoint: Octokit.web_endpoint) }
    let(:event_name) { 'create_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_create_event }

    it { expect(subject[:status]).to eq 'created tag:3.3.3' }
    it {
      expect(subject[:title]).to eq <<-TITLE.pretty_heredoc
        Sinatra inspired web development framework for node.js -- insanely fast,
        flexible, and simple
      TITLE
    }
    it { expect(subject[:body]).to be_nil }
    it { expect(subject[:link]).to eq 'https://github.com//visionmedia/express' }
  end

  describe '#parse_commit_comment_event' do
    let(:event_name) { 'commit_comment_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_commit_comment_event }

    it { expect(subject[:status]).to eq 'commented on commit' }
    it { expect(subject[:title]).to eq '' }
    it { expect(subject[:body]).to be_an_instance_of Array }
    it { expect(subject[:body][0]).to include 'AFAIK' }
    it { expect(subject[:body]).to have(1).items }
    it { expect(subject[:link]).to eq 'https://github.com/boxen/our-boxen/commit/08009e9b0718869d269d9b1c48383e6e145950db#commitcomment-3583654' }
  end

  describe '#parse_delete_event' do
    let(:client) { double(Octokit::Client, web_endpoint: Octokit.web_endpoint) }
    let(:event_name) { 'delete_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_delete_event }

    it { expect(subject[:status]).to eq 'deleted branch:jefftk-fix-beacon' }
    it { expect(subject[:title]).to be_nil }
    it { expect(subject[:body]).to be_nil }
    it { expect(subject[:link]).to eq 'https://github.com//pagespeed/ngx_pagespeed' }
  end

  describe '#parse_fork_event' do
  end

  describe '#parse_fork_apply_event' do
    it { expect(parser.parse_fork_apply_event).to eq({}) }
  end

  describe '#parse_public_event' do
    let(:event_name) { 'public_event' }

    before do
      client.stub(:web_endpoint).and_return Octokit.web_endpoint
      parser.instance_variable_set(:@event, event)
    end

    subject { parser.parse_public_event }

    it { expect(subject[:status]).to eq 'published JustinBeaudry/brudniakbook' }
    it { expect(subject[:title]).to be_nil }
    it { expect(subject[:body]).to be_nil }
    it { expect(subject[:link]).to eq 'https://github.com//JustinBeaudry/brudniakbook' }
  end
end
