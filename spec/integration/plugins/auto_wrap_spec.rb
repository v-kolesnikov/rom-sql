RSpec.describe 'Plugins / :auto_wrap' do
  with_adapters do
    include_context 'users and tasks'

    describe '#for_wrap' do
      shared_context 'joined tuple' do
        it 'returns joined tuples' do
          task_with_user = tasks
            .for_wrap({ id: :user_id }, users.name.relation)
            .where(tasks__id: 2)
            .one

          expect(task_with_user).to eql(
            id: 2, user_id: 1, title: "Jane's task", users_name: "Jane", users_id: 1
          )
        end
      end

      context 'when parent relation is registered under dataset name' do
        subject(:tasks) { container.relations[:tasks] }

        let(:users) { container.relations[:users] }

        before do
          conf.relation(:tasks)
          conf.relation(:users)
        end

        include_context 'joined tuple'
      end

      context 'when parent relation is registered under a custom name' do
        subject(:tasks) { container.relations[:tasks] }

        let(:users) { container.relations[:authors] }

        before do
          conf.relation(:tasks)
          conf.relation(:authors) { dataset :users }
        end

        include_context 'joined tuple'
      end
    end
  end
end
