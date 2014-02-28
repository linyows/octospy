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
        @repos << name if repos.empty? || !repos.include?(name)
      end

      def remove_repo(name)
        @repos.delete(name.to_sym) if !repos.empty? && repos.include?(name)
      end
    end
  end
end
