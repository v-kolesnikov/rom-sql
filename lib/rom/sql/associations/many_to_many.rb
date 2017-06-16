require 'rom/associations/many_to_many'

module ROM
  module SQL
    module Associations
      class ManyToMany < ROM::Associations::ManyToMany
        # @api public
        def call(target_rel = nil)
          assocs = join_relation.associations

          left = target_rel ? assocs[target.name].(target_rel) : assocs[target.name].()
          right = target

          schema =
            if left.schema.key?(foreign_key)
              if target_rel
                target_rel.schema.merge(left.schema.project(foreign_key))
              else
                left.schema.project(*(right.schema.map(&:name) + [foreign_key]))
              end
            else
              right.schema.merge(join_relation.schema.project(foreign_key))
            end.qualified

          relation = left.join(source.name.dataset, join_keys)

          if view
            apply_view(schema, relation)
          else
            schema.(relation)
          end
        end

        # @api public
        def join(type, source = self.source, target = self.target)
          through_assoc = source.associations[through]
          joined = through_assoc.join(type, source)
          joined.__send__(type, target.name.dataset, join_keys).qualified
        end

        # @api public
        def join_keys
          with_keys { |source_key, target_key|
            { source[source_key].qualified => join_relation[target_key].qualified }
          }
        end

        # @api private
        def persist(children, parents)
          join_tuples = associate(children, parents)
          join_relation.multi_insert(join_tuples)
        end
      end
    end
  end
end