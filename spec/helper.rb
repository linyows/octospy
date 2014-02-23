# coding: utf-8

require 'simplecov'
require 'coveralls'
require 'octospy'
require 'rspec'
require 'json'
require 'hashie'
require 'awesome_print'
require 'webmock/rspec'
require 'vcr'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

WebMock.disable_net_connect!(allow: 'coveralls.io')
RSpec.configure { |c| c.include WebMock::API }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end

  def no_lf
    gsub(/\n|\r\n/, ' ')
  end

  def pretty_heredoc
    strip_heredoc.no_lf.strip
  end

  def escaping
    gsub(/https?:\/\//, '').gsub(/\/|\./, '_')
  end
end

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.read(fixture_path + '/' + file)
end

def decode(file)
  JSON.parse(fixture file)
end

def json_response(file)
  {
    body: fixture(file),
    headers: { content_type: 'application/json; charset=utf-8' }
  }
end

def method_missing(method, *args, &block)
  if method =~ /^a_(get|post|put|delete)$/
    a_request(Regexp.last_match[1].to_sym, *args, &block)
  elsif method =~ /^stub_(get|post|put|delete|head|patch)$/
    stub_request(Regexp.last_match[1].to_sym, *args, &block)
  else
    super
  end
end

def support_path
  File.expand_path('../support', __FILE__)
end

Dir["#{support_path}/**/*.rb"].each { |f| require f }
