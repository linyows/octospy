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
      debug 'thread_start', <<-MSG.compact
          api_request_interval(A): #{Octospy.api_request_interval},
          repoisitory_count(R): #{@repositories.count},
          worker_interval(W): #{Octospy.worker_interval},
          work_interval(A*R+W): #{work_interval}
        MSG

      @thread = Thread.start { loop { work } }
    end

    def work
      notify_recent_envets
      debug 'sleep', work_interval
      sleep work_interval
    rescue => e
      error e.message
      debug 'sleep', work_interval
      sleep worker_interval
    end

    def api_requestable?
      limit = Octokit.rate_limit
      if !limit.limit.zero? && limit.remaining.zero?
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
        events = ::Octokit.repository_events(repo.to_s)
        arr.concat events

        debug_attrs = <<-MSG.compact
          repo: #{repo},
          limit: #{Octokit.rate_limit.remaining}/#{Octokit.rate_limit.limit},
          reset: #{Octokit.rate_limit.resets_at.strftime('%H:%M:%S')} *after #{Octokit.rate_limit.resets_in}sec,
        MSG

        if !events.nil? && !events.empty?
          debug_attrs << ' ' + <<-MSG.compact
            first: #{events.first.type},
            last: #{events.last.type}
          MSG
        end

        debug 'get_event', debug_attrs
      end
    end

    def skipping?(event)
      case
      when event.nil?,
           @last_event_id.nil? && while_ago >= event.created_at,
          !@last_event_id.nil? && @last_event_id >= event.id.to_i
        true
      else
        false
      end
    end

    def notify_recent_envets
      events = repository_events
      return if events.count.zero?

      last_event = events.sort_by(&:id).last
      debug 'last_event', <<-MSG.compact
          repo: #{last_event.repo.name},
          event_type: #{last_event.type},
          #{@last_event_id.nil? ?
            "while_ago: #{while_ago}, created_at: #{last_event.created_at}" :
            "last_id: #{@last_event_id}, current_id: #{last_event.id}"}
        MSG

      # ascending by event.id
      events.sort_by(&:id).each { |event|
        next if skipping?(event)

        parsed_event = Octospy.parse(event)

        unless parsed_event
          debug 'could_not_parse', <<-MSG.compact
              repo: #{event.repo.name},
              event: #{event.type}
            MSG
          next
        end

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
