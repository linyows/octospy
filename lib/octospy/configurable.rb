module Octospy
  module Configurable
    OPTIONS_KEYS = %i(
        channels
        server
        nick
        github_api_endpoint
        github_web_endpoint
        github_login
        github_token
      ).freeze

    attr_accessor(*OPTIONS_KEYS)

    class << self
      def keys
        @keys ||= OPTIONS_KEYS
      end
    end

    DEFAULT_GITHUB_API_ENDPOINT = ENV['GITHUB_API_ENDPOINT'] || 'https://api.github.com'
    DEFAULT_GITHUB_WEB_ENDPOINT = ENV['GITHUB_WEB_ENDPOINT'] || 'https://github.com'
    DEFAULT_NICK = ENV['NICK'] || 'octospy'

    def configure
      yield self
    end

    def options
      Hash[Octospy::Configurable.keys.map{ |key|
        [key, instance_variable_get(:"@#{key}")]
      }]
    end

    def setup
      @github_api_endpoint = DEFAULT_GITHUB_API_ENDPOINT
      @github_web_endpoint = DEFAULT_GITHUB_WEB_ENDPOINT
      @nick = DEFAULT_NICK
      @channels = if ENV['CHANNELS']
          ENV['CHANNELS'].gsub(/\s|#/, '').split(',').map { |ch| "##{ch}" }
        else
          ''
        end
      @server = ENV['SERVER']
      @github_login = ENV['GITHUB_LOGIN']
      @github_token = ENV['GITHUB_TOKEN']
    end
  end
end
