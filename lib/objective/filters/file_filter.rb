# frozen_string_literal: true

module Objective
  module Filters
    class FileFilter < Objective::Filter
      Options = OpenStruct.new(
        nils: Objective::DENY,
        invalid: Objective::DENY,
        strict: false,
        upload: false,
        size: nil
      )

      private

      def coerce_error(coerced)
        return :file unless respond_to_all?(coerced)
      end

      def respond_to_all?(coerced)
        methods = %i[read size]
        methods.concat(%i[original_filename content_type]) if options.upload
        methods.map { |method| coerced.respond_to?(method) }.all?
      end

      def validate(coerced)
        return :size if options.size && coerced.size > options.size
      end
    end
  end
end
