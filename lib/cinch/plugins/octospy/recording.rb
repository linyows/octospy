module Cinch
  module Plugins
    class Octospy
      module Recording
        def self.included(base)
          base.class_eval do
            match(/watch ([\w\-\.]+)\/([\w\-\.]+)$/, method: :watch_repository)
            match(/unwatch ([\w\-\.]+)\/([\w\-\.]+)$/, method: :unwatch_repository)
            match(/watch ([\w\-\.]+)$/, method: :watch_repositories)
            match(/unwatch ([\w\-\.]+)$/, method: :unwatch_repositories)
            match(/show watched( repos(itories)?)?/, method: :show_watched_repositories)
          end
        end

        def watch_repository(m, owner, project)
          repo = "#{owner}/#{project}"

          unless ::Octokit.repository?(repo)
            m.reply "Sorry, '#{repo}' not found"
            return
          end

          ::Octospy::Recordable.add_channel m.channel.name
          ::Octospy::Recordable.channel(m.channel.name).add_repo(repo)

          restart(m)
          m.reply "started to watch the #{repo} events"
        end

        def watch_repositories(m, owner)
          user = ::Octokit.user?(owner)

          unless user
            m.reply "Sorry, '#{owner}' not found"
            return
          end

          ::Octospy::Recordable.add_channel m.channel.name
          method = "#{'org_' if user.type == 'Organization'}repos".to_sym
          repos = ::Octokit.send(method, owner).map { |repo|
            ::Octospy::Recordable.channel(m.channel.name).add_repo(repo.full_name)
            repo.full_name
          }

          if repos.count > 0
            m.reply "started to watch events of #{repos.count} repositories"
            restart(m)
          end
        end

        def unwatch_repository(m, owner, project)
          repo = "#{owner}/#{project}"

          unless ::Octokit.repository?(repo)
            m.reply "sorry, '#{repo}' not found"
            return
          end

          ::Octospy::Recordable.channel(m.channel.name).remove_repo(repo)

          restart(m)
          m.reply "stopped to watch the #{repo} events"
        end

        def unwatch_repositories(m, owner)
          repos = ::Octospy::Recordable.channel(m.channel.name).repos.each_with_object([]) do |repo, obj|
            next unless repo.split('/').first == owner
            ::Octospy::Recordable.channel(m.channel.name).remove_repo(repo)
            opj << repo
          end

          if repos.count > 0
            if ::Octospy::Recordable.channel(m.channel.name).repos.count > 0
              m.reply "stopped to watch events of #{repos.count} repositories"
              restart(m)
            else
              m.reply "stopped job so no watched repository"
              stop(m)
            end
          end
        end

        def unwatch_all(m)
        end

        def show_watched_repositories(m)
          channel = ::Octospy::Recordable.channel(m.channel.name)

          if channel.nil? || channel.repos.nil? || channel.repos.empty?
            m.reply 'nothing'
            return
          end

          channel.repos.each.with_index(1) do |repo, i|
            m.reply "#{i} #{repo}"
          end
        end
      end
    end
  end
end
