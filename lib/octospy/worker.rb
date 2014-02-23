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
            sleep 30
          rescue => e
            puts e.message
            sleep 30
          end
        end
      end
    end

    def events
      @repositories.each_with_object([]) do |repo, arr|
        arr.concat ::Octokit.repository_events(repo)
      end
    end

    def watch_repositories
      events.sort_by(&:id).reverse_each { |event|
        if @last_event_id.nil?
          next if Time.now.utc - (60*60) >= event.created_at
        else
          next if @last_event_id >= event.id
        end

        parsed_event = Octospy.parse(event)
        next unless parsed_event

        @last_event_id = event.id
        parsed_event.each { |p| @block.call p[:message] }
      }
    end
  end
end
