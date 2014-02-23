require 'helper'

describe Octospy::Parser do
  include_context :parser_params

  describe '#initialize' do
    it { expect(parser).to be_an_instance_of Octospy::Parser }
  end

  describe '#default_params' do
    it { expect(parser.default_params).to eq default_params }
  end

  describe '#parse' do
    it {
      expect(parser).to receive(:parsing_method).once.and_return(parsing_method)
      expect(parser).to receive(parsing_method).once.and_return(parsed_params)
      expect(parser).to receive(:build).once.with(merged_params).and_return(built_params)
      expect(parser.parse event).to eq built_params
    }
  end

  describe '#build' do
    it {
      expect_any_instance_of(String).to receive(:shorten).once.and_return('http://git.io/A0ARbg')
      expect(parser.build merged_params).to eq built_params
    }
  end

  describe '#parsing_method' do
    let(:event) { double(Octokit::Client, type: 'FooBarBaz') }
    before { parser.instance_variable_set(:@event, event) }
    it { expect(parser.parsing_method).to eq :parse_foo_bar_baz }
  end

  describe '#behavior_color' do
    {
      pink: 'created',
      yellow: 'commented',
      lime: 'pushed',
      orange: 'forked',
      brown: 'closed',
      red: 'deleted',
      green: 'edited',
      blue: 'published',
      rainbow: 'started',
      seven_eleven: 'followed',
      aqua: 'foobar'
    }.each { |color, word|
      it { expect(parser.behavior_color word).to eq color }
    }
  end

  describe '#colorize_to' do
    let(:sentence) { 'created issue' }

    it {
      expect_any_instance_of(StringIrc).to receive(:pink).
        once.with(no_args).and_call_original
      expect(parser.colorize_to sentence).to eq "\u000313#{sentence}\u000F"
    }
  end
end
