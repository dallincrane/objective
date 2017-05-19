# frozen_string_literal: true
module Objective
  module Filters
    class DuckFilter < Objective::Filter
      private

      def coerce_error(coerced)
        return :duck unless respond_to_all?(coerced)
      end

      def respond_to_all?(coerced)
        Array.wrap(options[:methods]).map do |method|
          coerced.respond_to?(method)
        end.all?
      end
    end
  end
end