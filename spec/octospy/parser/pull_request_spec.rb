require 'helper'

describe Octospy::Parser do
  include_context :parser_params

  describe '#parse_pull_request_event' do
    let(:event_name) { 'pull_request_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_pull_request_event }

    it { expect(subject[:status]).to eq 'closed pull request #11363' }
    it { expect(subject[:title]).to eq 'Fix 2 grammatical errors/typos in Active Record Basics guide.' }
    it { expect(subject[:body]).to eq [] }
    it { expect(subject[:link]).to eq 'https://github.com/rails/rails/pull/11363' }
  end

  describe '#parse_pull_request_review_comment_event' do
    let(:pull) { double(Octokit::Client, title: 'Mocking title') }
    let(:client) { double(Octokit::Client, pull: pull) }
    let(:event_name) { 'pull_request_review_comment_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_pull_request_review_comment_event }

    it { expect(subject[:status]).to eq 'commented on pull request' }
    it { expect(subject[:title]).to eq 'Mocking title: packages/ember-handlebars/lib/helpers/collection.js' }
    it { expect(subject[:body]).to be_an_instance_of Array }
    it { expect(subject[:body][0]).to include 'Of course.' }
    it { expect(subject[:body]).to have(1).items }
    it { expect(subject[:link]).to eq 'https://github.com/emberjs/ember.js/pull/2930#discussion_r5064430' }
  end
end
