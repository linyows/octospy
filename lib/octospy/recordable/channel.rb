module Octospy
  module Recordable
    class Channel
      attr_reader :name

      def initialize(name)
        @name = name.to_sym
      end

      def repos
        @repos ||= []
      end

      def add_repo(name)
        repos << name.to_sym if !repos.include?(name.to_sym)
      end

      def add_repos(names = nil)
        return if names.nil? || names.empty?
        repos.concat(names.map { |repo|
          repo.to_sym unless repos.include?(repo.to_sym) }.compact)
      end

      def remove_repo(name)
        repos.delete(name.to_sym) if repos.include?(name.to_sym)
      end

      def remove_repos(names = nil)
        return if names.nil? || names.empty?
        repos.delete_if { |repo| names.include? repo.to_s }
      end
    end
  end
end
