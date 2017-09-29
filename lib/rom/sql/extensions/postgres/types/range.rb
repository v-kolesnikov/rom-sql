module ROM
  module SQL
    module Postgres
      module Values
        Range = ::Struct.new(:lower, :upper, :lower_bound, :upper_bound)
      end

      module Types
        EmptyRange = SQL::Types.Value('empty')

        RANGE_REGEXP = /
          (?<lower_bound>\[|\()
          (?<lower>.*)
          (?:,\s*)
          (?<upper>.*)
          (?<upper_bound>\]|\))
        /x

        def self.Range(name, subtype)
          Type(name) do
            read = SQL::Types.Constructor(Values::Range) do |value|
              RANGE_REGEXP.match(value) do |match|
                Values::Range.new(
                  subtype[match[:lower]],
                  subtype[match[:upper]],
                  match[:lower_bound].to_sym,
                  match[:upper_bound].to_sym
                )
              end
            end

            type = SQL::Types::String.constructor do |range|
              format('%s%s,%s%s',
                     range.lower_bound,
                     range.lower,
                     range.upper,
                     range.upper_bound)
            end

            type.meta(read: read, subtype: subtype)
          end
        end

        Int4Range = Range('int4range', SQL::Types::Coercible::Int)
        Int8Range = Range('int8range', SQL::Types::Coercible::Int)
        NumRange  = Range('numrange',  SQL::Types::Coercible::Int)

        TsRange   = Range('tsrange',   SQL::Types::Form::Time)
        TsTzRange = Range('tstzrange', SQL::Types::Form::Time)
        DateRange = Range('daterange', SQL::Types::Form::Date)

        module RangeMethods
        end
      end
    end
  end
end
