module Octospy
  class Parser
    module Release
      def parse_release_event
        {
          status: "#{@event.payload.release.draft ? 'published' : 'saved draft'} release",
          title: "#{@event.payload.release.name}",
          body: "#{@event.payload.release.body}".split_lfbl,
          link: "#{Octokit.web_endpoint}#{@event.repo.name}/releases/#{@event.payload.release.tag_name}"
        }
      end
    end
  end
end
