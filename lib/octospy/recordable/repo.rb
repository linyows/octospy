module Octospy
  module Recordable
    class Repo
      attr_accessor :name, :last_event_id

      def initialize(name)
        @name = name.to_sym
        @last_event_id = nil
      end

      def clear!
        @last_event_id = nil
      end
    end
  end
end
