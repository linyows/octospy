require 'cinch'
require 'octokit'
require 'dotenv'

require 'cinch/plugins/management'
require 'cinch/plugins/octospy'
require 'octospy/configurable'
require 'octospy/recordable'
require 'octospy/parser'
require 'octospy/worker'
require 'octospy/octokit/client'

module Octospy
  class << self
    include Octospy::Configurable

    def parse(event)
      Octospy::Parser.new(event).parse
    end

    def worker(repositories, &block)
      Octospy::Worker.new(repositories, &block)
    end

    def irc_bot
      Octokit.configure do |c|
        c.api_endpoint = Octospy.github_api_endpoint if Octospy.github_api_endpoint
        c.web_endpoint = Octospy.github_web_endpoint if Octospy.github_web_endpoint
        c.login        = Octospy.github_login
        c.access_token = Octospy.github_token
      end

      Cinch::Bot.new do
        configure do |c|
          c.server          = Octospy.server
          c.nick            = Octospy.nick
          c.channels        = Octospy.channels
          c.port            = Octospy.port if Octospy.port
          c.password        = Octospy.password if Octospy.password
          c.ssl.use         = Octospy.ssl if Octospy.ssl
          c.plugins.plugins = [
            Cinch::Plugins::Management,
            Cinch::Plugins::Octospy
          ]
        end
      end
    end

    def daemonize
      Process.daemon(nochdir: nil, noclose: true)
      File.open(Octospy.pid_file, 'w') { |f| f << Process.pid }
      log = File.new(Octospy.log_file, 'a')
      log.sync = Octospy.sync_log
      STDIN.reopen '/dev/null'
      STDOUT.reopen log
      STDERR.reopen STDOUT
    end

    def run
      self.daemonize if Octospy.daemonize
      self.irc_bot.start
    end
  end

  Dotenv.load ENV['DOTENV'] || '.env'
  Octospy.setup
end
