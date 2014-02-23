require 'helper'

describe Octospy::Parser do
  include_context :parser_params

  describe '#parse_issues_event' do
    let(:event_name) { 'issues_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_issues_event }

    it { expect(subject[:status]).to eq 'opened issue #430' }
    it { expect(subject[:title]).to eq 'mismatching hashes for css' }
    it { expect(subject[:body]).to be_an_instance_of Array }
    it { expect(subject[:body]).to include 'Server: nginx/1.4.1' }
    it { expect(subject[:body]).to have(40).items }
    it { expect(subject[:link]).to eq 'https://github.com/pagespeed/ngx_pagespeed/issues/430' }
  end

  describe '#parse_issue_comment_event' do
    let(:event_name) { 'issue_comment_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_issue_comment_event }

    it { expect(subject[:status]).to eq 'commented on issue #582' }
    it { expect(subject[:title]).to eq 'Remove `engines` from package.json.' }
    it { expect(subject[:body]).to be_an_instance_of Array }
    it { expect(subject[:body][0]).to include 'anything?' }
    it { expect(subject[:body]).to have(1).items }
    it { expect(subject[:link]).to eq 'https://github.com/bower/bower/issues/582#issuecomment-20416296' }
  end
end
