module Octospy
  class Parser
    module Gist
      def parse_gist_event
        unless @event.payload.gist.description.eql? ''
          title = @event.payload.gist.description
        else
          title = ''
        end

        {
          status: "#{@event.payload.action}d gist",
          title: title,
          link: @event.payload.gist.html_url,
          none_repository: true
        }
      end
    end
  end
end
