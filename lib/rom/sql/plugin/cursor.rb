module ROM
  module SQL
    module Plugin
      module Cursor
        # Paginate a relation by cursor
        #
        # @example
        #   rom.relations[:users].class.use :cursor
        #   rom.relations[:users].after(100)
        #
        # @return [Relation]
        #
        # @api public
        def after(value)
          where { schema[schema.primary_key_name] > value }
        end

        # Paginate a relation by cursor
        #
        # @example
        #   rom.relations[:users].class.use :cursor
        #   rom.relations[:users].before(100)
        #
        # @return [Relation]
        #
        # @api public
        def before(value)
          where { schema[schema.primary_key_name] < value }
        end
      end
    end
  end
end
