require 'helper'

describe Octospy::Parser do
  include_context :parser_params

  describe '#parse_gollum_event' do
    let(:event_name) { 'gollum_event' }
    before { parser.instance_variable_set(:@event, event) }

    subject { parser.parse_gollum_event }

    it { expect(subject[:status]).to eq 'edited the component/component wiki' }
    it { expect(subject[:title]).to eq 'Components' }
    it { expect(subject[:body]).to be_nil }
    it { expect(subject[:link]).to eq 'https://github.com/component/component/wiki/Components/_compare/3df147%5E...3df147' }
  end
end
