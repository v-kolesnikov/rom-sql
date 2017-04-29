require 'set'
require 'rom/sql/schema/inferrer'
require 'rom/sql/extensions/postgres/types'

module ROM
  module SQL
    class Schema
      class PostgresInferrer < Inferrer[:postgres]
        defines :db_array_type_matcher, :db_character_type_regex,
                :db_numeric_types, :db_type_mapping

        db_character_type_regex(
          # Match { text | character [ (n) ] | character varying [ (n) ] }
          /(text|character(?: varying)?(?:\((?<limit>\d+)\))?)/
        )

        db_numeric_types %w(
          smallint integer bigint
          decimal numeric real
          double\ precision serial bigserial
        ).to_set.freeze

        db_type_mapping(
          'uuid'  => Types::PG::UUID,
          'money' => Types::PG::Money,
          'bytea' => Types::Blob,
          'json'  => Types::PG::JSON,
          'jsonb' => Types::PG::JSONB,
          'inet' => Types::PG::IPAddress,
          'cidr' => Types::PG::IPAddress,
          'macaddr' => Types::String,
          'point' => Types::PG::PointT,
          'xml' => Types::String,
          'hstore' => Types::PG::HStore,
          'line' => Types::PG::LineT,
          'circle' => Types::PG::CircleT,
          'box' => Types::PG::BoxT,
          'lseg' => Types::PG::LineSegmentT,
          'polygon' => Types::PG::PolygonT,
          'path' => Types::PG::PathT
        ).freeze

        db_array_type_matcher Sequel::Postgres::PGArray::EMPTY_BRACKET

        private

        def map_pk_type(type, db_type)
          if numeric?(type, db_type)
            type = self.class.numeric_pk_type
          else
            type = map_type(type, db_type)
          end

          type.meta(primary_key: true)
        end

        def map_type(ruby_type, db_type, enum_values: nil, **_)
          if db_type.end_with?(self.class.db_array_type_matcher)
            Types::PG::Array(db_type)
          elsif enum_values
            Types::String.enum(*enum_values)
          elsif self.class.db_type_mapping[db_type]
            self.class.db_type_mapping[db_type]
          elsif db_type.start_with?('timestamp')
            Types::Time
          elsif db_type.match(self.class.db_character_type_regex)
            limit = Regexp.last_match[:limit]
            limit ? Types::String.meta(limit: limit.to_i) : Types::String
          else
            super
          end
        end

        def numeric?(ruby_type, db_type)
          self.class.db_numeric_types.include?(db_type) || ruby_type == :integer
        end
      end
    end
  end
end
