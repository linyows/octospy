require 'helper'

describe Octospy::Parser do
  include_context :parser_params

  describe '#parse_team_add_event' do
    let(:event_name) { 'team_add_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_team_add_event }

    it { expect(subject[:status]).to eq 'add team' }
    it { expect(subject[:title]).to eq 'dev' }
    it { expect(subject[:body]).to be_nil }
    it { expect(subject[:link]).to be_nil }
  end

  describe '#parse_member_event' do
    let(:event_name) { 'member_event' }

    before do
      client.stub(:web_endpoint).and_return Octokit.web_endpoint
      parser.instance_variable_set(:@event, event)
    end

    subject { parser.parse_member_event }

    it { expect(subject[:status]).to eq 'added member' }
    it { expect(subject[:title]).to eq 'jamiesarahg' }
    it { expect(subject[:body]).to be_nil }
    it { expect(subject[:link]).to eq 'https://github.com//jamiesarahg' }
  end
end
