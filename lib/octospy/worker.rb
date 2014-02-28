module Octospy
  class Worker
    attr_reader :thread

    def initialize(repositories, &block)
      @repositories = repositories
      @block = block
      @last_event_id = nil
      thread_loop
    end

    def thread_loop
      @thread = Thread.start do
        loop do
          begin
            watch_repositories
            sleep Octospy.worker_interval
          rescue => e
            @block.call "Octospy Error: #{e.message}"
            sleep Octospy.worker_interval
          end
        end
      end
    end

    def events
      @repositories.each_with_object([]) do |repo, arr|
        if Octokit.rate_limit.remaining.zero?
          @block.call "ヾ(;´Д`)ﾉ #{::Octokit.rate_limit}"
          break
        end

        arr.concat ::Octokit.repository_events(repo)
      end
    end

    def while_ago
      Time.now.utc - (60 * 30)
    end

    def watch_repositories
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
