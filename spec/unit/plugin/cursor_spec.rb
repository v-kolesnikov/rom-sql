require 'rom/sql/plugin/cursor'

RSpec.describe 'Plugin / Cursor', seeds: false do
  include_context 'users'

  with_adapters do
    before do
      9.times { |i| conn[:users].insert(name: "User #{i}") }
      container.relations[:users].class.use :cursor
    end

    describe '#before' do
      it 'return relation satisfying the condition' do
        expect(container.relations[:users].before(5).count).to eq 4
        expect(container.relations[:users].before(1).count).to eq 0
      end
    end

    describe '#after' do
      it 'return relation satisfying the condition' do
        expect(container.relations[:users].after(7).count).to eq 2
        expect(container.relations[:users].after(12).count).to eq 0
      end
    end
  end
end
