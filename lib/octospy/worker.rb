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
      @thread = Thread.start do
        loop do
          begin
            notify_recent_envets
            sleep work_interval
          rescue => e
            @block.call "Octospy Error: #{e.message}"
            sleep worker_interval
          end
        end
      end
    end

    def api_requestable?
      limit = Octokit.rate_limit!
      if limit.remaining.zero?
        @block.call "ヾ(;´Д`)ﾉ #{limit}"
        false
      end
      true
    # No rate limit for white listed users
    rescue Octokit::NotFound
      true
    end

    def repository_events
      @repositories.each_with_object([]) do |repo, arr|
        break unless api_requestable?
        sleep Octospy.api_request_interval
        arr.concat ::Octokit.repository_events(repo)
      end
    end

    def while_ago
      Time.now.utc - (60 * 30)
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
        parsed_event.each { |p| @block.call p[:message] }
      }
    end
  end
end
