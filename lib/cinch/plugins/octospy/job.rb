require 'octospy'

module Cinch
  module Plugins
    class Octospy
      module Job
        def self.included(base)
          base.class_eval do
            match('start', method: :start_with_message)
            match('stop', method: :stop_with_message)
            match('restart', method: :restart_with_message)
          end

          Channel.class_eval do
            attr_accessor :job_thread, :last_github_event_id

            define_method(:job_thread_alive?) do
              @job_thread && @job_thread.alive?
            end
          end
        end

        def start_with_message(m)
          channel = ::Octospy::Recordable.channel(m.channel.name)

          if channel.nil? || channel.repos.nil? || channel.repos.empty?
            m.reply 'no repository watched'
            return
          end

          if m.channel.job_thread_alive?
            m.reply 'already started'
            return
          end

          start(m)
          m.reply 'started'
        end

        def stop_with_message(m)
          unless m.channel.job_thread_alive?
            m.reply 'not started'
            return
          end

          stop(m)
          m.reply 'stopped'
        end

        def restart_with_message(m)
          if restart(m)
            m.reply 'restarted'
          else
            m.reply 'not started'
          end
        end

        def start(m)
          repos = ::Octospy::Recordable.channel(m.channel.name).repos
          channel = m.channel

          worker = ::Octospy.worker(repos) do |message|
            case message.class.name
            when 'String'
              message.each_char.each_slice(512) do |string|
                channel.notice string.join
                sleep 1
              end
            when 'Array'
              message.each do |line|
                # maximum line length 512
                # http://www.mirc.com/rfc2812.html
                line.each_char.each_slice(512) do |string|
                  channel.notice string.join
                  sleep 1
                end
              end
            end
          end

          m.channel.job_thread = worker.thread
        end

        def stop(m)
          m.channel.job_thread.kill
        end

        def restart(m)
          if m.channel.job_thread_alive?
            restart!(m)
            true
          else
            false
          end
        end

        def restart!(m)
          stop(m) if m.channel.job_thread_alive?
          start(m)
        end
      end
    end
  end
end
