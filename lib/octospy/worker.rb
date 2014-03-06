module Octospy
  class Worker
    attr_reader :thread

    def initialize(repositories, &block)
      @repositories = repositories
      @block = block
      @last_event_id = nil
      thread_loop
    end

    def work_interval
      (Octospy.api_request_interval * @repositories.count) + Octospy.worker_interval
    end

    def thread_loop
      @thread = Thread.start { loop { work } }
    end

    def work
      notify_recent_envets
      sleep work_interval
    rescue => e
      error e.message
      sleep worker_interval
    end

    def api_requestable?
      limit = Octokit.rate_limit
      if limit.remaining.zero?
        notify "ヾ(;´Д`)ﾉ #{limit}"
        false
      else
        true
      end
    # No rate limit for white listed users
    rescue Octokit::NotFound
      true
    end

    def repository_events
      @repositories.each_with_object([]) do |repo, arr|
        break unless api_requestable?

        sleep Octospy.api_request_interval
        arr.concat ::Octokit.repository_events(repo.to_sym)
      end


    end

    def notify_recent_envets
      events = repository_events
      return if events.count.zero?

      # ascending by event.id
      events.sort_by(&:id).each { |event|
        case
        when @last_event_id.nil? && while_ago >= event.created_at
          next
        when !@last_event_id.nil? && @last_event_id >= event.id.to_i
          next
        end

        parsed_event = Octospy.parse(event)
        next unless parsed_event

        @last_event_id = event.id.to_i
        parsed_event.each { |p| notify p[:message] }
      }
    end

    private

    def while_ago
      Time.now.utc - (60 * 30)
    end

    def notify(message)
      @block.call message
    end

    def debug(name, message = nil)
      return unless Octospy.debug

      prefix = '[DEBUG]'.colorize_for_irc.orange
      info = name.colorize_for_irc.bold
      @block.call "#{prefix} #{info} #{message}"
    end

    def error(message)
      prefix = '[ERROR]'.colorize_for_irc.red
      @block.call "#{prefix} #{message}"
    end
  end
end
