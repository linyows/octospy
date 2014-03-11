module Octospy
  module Configurable
    OPTIONS_KEYS = %i(
        channels
        server
        port
        ssl
        password
        nick
        debug
        daemonize
        sync_log
        pid_file
        log_file
        worker_interval
        api_request_interval
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
      @github_api_endpoint  = ENV['GITHUB_API_ENDPOINT']
      @github_web_endpoint  = ENV['GITHUB_WEB_ENDPOINT']
      @nick                 = ENV['NICK'] || 'octospy'
      @server               = ENV['SERVER']
      @port                 = ENV['PORT']
      @ssl                  = !!ENV['SSL']
      @debug                = !!ENV['DEBUG']
      @daemonize            = !!ENV['DAEMONIZE']
      @sync_log             = "#{ENV['SYNC_LOG'] || true}".to_boolean
      @pid_file             = ENV['PID_FILE'] || default_pid_file
      @log_file             = ENV['LOG_FILE'] || default_log_file
      @password             = ENV['PASSWORD']
      @worker_interval      = ENV['WORKER_INTERVAL'] ? ENV['WORKER_INTERVAL'].to_i : 30 #sec
      # you can make up to 20 requests per minute.
      # http://developer.github.com/v3/search/#rate-limit
      @api_request_interval = ENV['API_REQUEST_INTERVAL'] ? ENV['API_REQUEST_INTERVAL'].to_i : 3 #sec
      @github_login         = ENV['GITHUB_LOGIN']
      @github_token         = ENV['GITHUB_TOKEN']
      @channels             = ENV['CHANNELS'] ? ENV['CHANNELS'].gsub(/\s|#/, '').split(',').
        map { |ch| "##{ch}" } : nil
      @cinch_config_block   = nil
    end

    private

    def default_pid_file
      File.join(File.expand_path('../../../tmp/pids', __FILE__), "#{@nick}")
    end

    def default_log_file
      File.join(File.expand_path('../../../log', __FILE__), "#{@nick}.log")
    end
  end
end
