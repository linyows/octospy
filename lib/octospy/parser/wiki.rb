module Octospy
  class Parser
    module Wiki
      def parse_gollum_event
        action = @event.payload.pages[0].action
        title = @event.payload.pages[0].title
        sha = @event.payload.pages[0].sha[0,6]
        url = "#{Octokit.web_endpoint}#{@event.repo.name}/wiki"
        url += "/#{title}/_compare/#{sha}" if action == 'edited'

        {
          status: "#{action} the #{@event.repo.name} wiki",
          title: title,
          link: url
        }
      end
    end
  end
end
