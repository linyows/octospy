require 'helper'

describe Octospy::Parser do
  include_context :parser_params

  describe '#parse_gist_event' do
    let(:event_name) { 'gist_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_gist_event }

    it { expect(subject[:status]).to eq 'created gist' }
    it { expect(subject[:title]).to eq 'testing activegist' }
    it { expect(subject[:body]).to be_nil }
    it { expect(subject[:link]).to eq 'https://gist.github.com/5993603' }
  end
end
