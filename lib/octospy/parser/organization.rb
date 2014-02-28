module Octospy
  class Parser
    module Organization
      def parse_team_add_event
        {
          status: "add team",
          title: @event.payload.team.name
        }
      end

      def parse_member_event
        user = @event.payload.member

        {
          status: "#{@event.payload.action} member",
          title: user.login,
          link: "#{Octokit.web_endpoint}#{user.login}"
        }
      end
    end
  end
end
