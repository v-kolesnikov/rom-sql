RSpec.describe 'ROM::SQL::Schema::PostgresInferrer::Range', :postgres, :helpers do
  include_context 'database setup'

  let(:pg_types) { ROM::SQL::Types::PG }

  before do
    conn.drop_table?(:test_inferrence)
    conn.create_table :test_inferrence do
      column :int4range, 'int4range'
      column :int8range, 'int8range'
      column :numrange,  'numrange'
      column :tsrange,   'tsrange'
      column :tstzrange, 'tstzrange'
      column :daterange, 'daterange'
    end
  end

  let(:gateway) { container.gateways[:default] }
  let(:source) { ROM::Relation::Name[:test_inferrence] }
  let(:inferrer) { ROM::SQL::Schema::Inferrer.new }

  subject(:schema) do
    empty = define_schema(:test_inferrence)
    empty.with(inferrer.(empty, gateway))
  end

  context 'inferring db-specific attributes' do
    it 'can infer attributes for dataset' do
      expect(schema.to_h).to eql(
        attributes(
          int4range: pg_types::Int4Range.optional.meta(name: :int4range),
          int8range: pg_types::Int8Range.optional.meta(name: :int8range),
          numrange:  pg_types::NumRange.optional.meta(name: :numrange),
          tsrange:   pg_types::TsRange.optional.meta(name: :tsrange),
          tstzrange: pg_types::TsTzRange.optional.meta(name: :tstzrange),
          daterange: pg_types::DateRange.optional.meta(name: :daterange)
        )
      )
    end
  end

  context 'with a column with bi-directional mapping' do
    before do
      conn.drop_table?(:test_bidirectional)
      conn.create_table(:test_bidirectional) do
        int4range :int4range
        int8range :int8range
        numrange  :numrange
        tsrange   :tsrange
        tstzrange :tstzrange
        daterange :daterange
      end

      conf.relation(:test_bidirectional) { schema(infer: true) }

      conf.commands(:test_bidirectional) do
        define(:create) do
          result :one
        end
      end
    end

    let(:range) { ROM::SQL::Postgres::Values::Range }

    let(:int4range) { range.new(0, 2, :'[', :')') }
    let(:int8range) { range.new(5, 7, :'[', :')') }
    let(:numrange)  { range.new(3, 9, :'[', :')') }

    let(:timestamp) { Time.parse('2017-09-25 07:00:00 +0000') }
    let(:tsrange)   { range.new(timestamp, timestamp + 3600 * 8, :'[', :')') }
    let(:tstzrange) { range.new(timestamp, timestamp + 3600 * 8, :'[', :')') }
    let(:daterange) { range.new(Date.today, Date.today.next_day, :'[', :')') }

    let(:create) { commands[:test_bidirectional].create }
    let(:relation) { container.relations[:test_bidirectional] }

    it 'writes and reads data & corrects data' do
      inserted = create.(
        int4range: int4range,
        int8range: int8range,
        numrange: numrange,
        tsrange: tsrange,
        tstzrange: tstzrange,
        daterange: daterange
      )

      expect(inserted).to eql(
        int4range: int4range,
        int8range: int8range,
        numrange: numrange,
        tsrange: tsrange,
        tstzrange: tstzrange,
        daterange: daterange
      )

      expect(relation.to_a).to eql([inserted])
    end
  end
end
