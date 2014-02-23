module Octokit
  class Client
    def user?(user, options = {})
      user(user)
    rescue Octokit::NotFound
      false
    end
  end
end
