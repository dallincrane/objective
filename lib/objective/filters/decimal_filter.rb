# frozen_string_literal: true

module Objective
  module Filters
    class DecimalFilter < Objective::Filter
      Options = OpenStruct.new(
        nils: Objective::DENY,
        invalid: Objective::DENY,
        empty: Objective::ALLOW,
        strict: false,
        delimiter: ', ',
        decimal_mark: '.',
        min: nil,
        max: nil,
        scale: nil
      )

      private

      def coerce(datum)
        if datum.is_a?(String)
          datum = datum.strip
          return datum if datum.empty?
        end

        return datum.to_d if datum.is_a?(Integer) || datum.is_a?(Float)

        return datum unless datum.is_a?(String)
        datum = datum.strip
        return datum if options.decimal_mark != '.' && !options.delimiter.include?('.') && datum.include?('.')

        clean_str = datum.tr(options.delimiter, '').tr(options.decimal_mark, '.')
        return datum unless clean_str =~ /\A[-+]?\d*\.?\d*\z/
        clean_str.to_d
      end

      def coerce_error(coerced)
        return :empty if coerced == '' && options.empty != Objective::ALLOW
        return :decimal unless coerced.is_a?(BigDecimal)
      end

      def validate(datum)
        return :min unless above_min?(datum)
        return :max unless below_max?(datum)
        return :scale unless within_scale?(datum)
      end

      def above_min?(datum)
        return true if options.min.nil?
        datum >= options.min
      end

      def below_max?(datum)
        return true if options.max.nil?
        datum <= options.max
      end

      def within_scale?(datum)
        return true if options.scale.nil?
        (datum - datum.round(options.scale)).zero?
      end
    end
  end
end
