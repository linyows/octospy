module Octospy
  module Configurable
    OPTIONS_KEYS = %i(
        channels
        server
        port
        ssl
        password
        nick
        worker_interval
        cinch_config_block
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

    def configure
      yield self
    end

    def cinch_config_block(&block)
      @cinch_config_block = block
    end

    def options
      Hash[Octospy::Configurable.keys.map{ |key|
        [key, instance_variable_get(:"@#{key}")]
      }]
    end

    def setup
      @github_api_endpoint = ENV['GITHUB_API_ENDPOINT']
      @github_web_endpoint = ENV['GITHUB_WEB_ENDPOINT']
      @nick                = ENV['NICK'] || 'octospy'
      @server              = ENV['SERVER']
      @port                = ENV['PORT']
      @ssl                 = !!ENV['SSL']
      @password            = ENV['PASSWORD']
      @worker_interval     = ENV['WORKER_INTERVAL'] ?
        ENV['WORKER_INTERVAL'].to_i : 30 #sec
      @github_login        = ENV['GITHUB_LOGIN']
      @github_token        = ENV['GITHUB_TOKEN']
      @channels            = ENV['CHANNELS'] ?
        ENV['CHANNELS'].gsub(/\s|#/, '').split(',').map { |ch| "##{ch}" } : nil
      @cinch_config_block  = nil
    end
  end
end
