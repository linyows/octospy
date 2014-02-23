module Octospy
  class Parser
    module Download
      def parse_download_event
        {
          status: "download #{@event.payload.name}",
          title: @event.payload.description,
          link: @event.payload.html_url
        }
      end
    end
  end
end
