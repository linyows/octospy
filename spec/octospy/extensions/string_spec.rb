require 'helper'

describe Octospy::Extensions::String do
  describe '#underscore' do
    it { expect('FooBar'.underscore).to eq 'foo_bar' }
    it { expect('fooBar'.underscore).to eq 'foo_bar' }
    it { expect('fooBaR'.underscore).to eq 'foo_ba_r' }
    it { expect('foo-bar'.underscore).to eq 'foo_bar' }
    it { expect('foo/bar'.underscore).to eq 'foo/bar' }
    it { expect('Foo::Bar'.underscore).to eq 'foo/bar' }
  end

  describe '#split_by_linefeed_except_blankline' do
    subject { sentence.split_by_linefeed_except_blankline }

    context 'when include line feed' do
      let(:sentence) {
        <<-RUBY.strip_heredoc
          That lucid breeze in Ihatov,
          Blue sky that has coolness at the bottom even in summer,
          Morio which has been decorated with beautiful forest,
          grass wave shines garishly in suburb.
        RUBY
      }

      it { expect(subject).to be_instance_of Array }
      it { expect(subject).to have(4).items }
      it { expect(subject[1]).to include 'Blue sky' }
    end

    context 'when not include line feed' do
      let(:sentence) { 'hi, hello world.' }

      it { expect(subject).to be_instance_of Array }
      it { expect(subject).to have(1).items }
    end

    it 'have alias_method' do
      expect(''.respond_to? :split_lfbl).to be_true
    end
  end

  describe '#colorize_for_irc' do
    let(:word) { 'hello world' }

    it 'call StringIrc#new' do
      expect(StringIrc).to receive(:new).with(word).once.and_call_original
      expect(word.colorize_for_irc).to be_instance_of StringIrc
    end
  end

  describe '#shorten_url' do
    context 'when it is in the url of github' do
      let(:url) { 'https://github.com/linyows/octospy' }
      let(:result) { 'http://git.io/aaaaa' }

      it 'call Octospy::Shortener.shorten_by_github' do
        expect(Octospy::Shortener).to receive(:shorten_by_github).and_return result
        expect(url.shorten_url).to eq result
      end
    end

    context 'when it is not in the url of github' do
      let(:url) { 'http://www.google.com/search?q=octospy' }
      let(:result) { 'http://goo.gl/aaaaa' }

      it 'call Octospy::Shortener.shorten_by_google' do
        expect(Octospy::Shortener).to receive(:shorten_by_google).and_return result
        expect(url.shorten_url).to eq result
      end
    end

    context 'when it is not in the url' do
      let(:url) { 'hello world' }
      let(:result) { url }

      it 'not call Octospy::Shortener' do
        expect(Octospy::Shortener).to_not receive(:shorten_by_github)
        expect(Octospy::Shortener).to_not receive(:shorten_by_google)
        expect(url.shorten_url).to eq result
      end
    end
  end
end
