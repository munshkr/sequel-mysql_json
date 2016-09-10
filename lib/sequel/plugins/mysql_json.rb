module Sequel
  module Plugins
    module MysqlJson
      module ClassMethods
        def set_dataset(*args)
          super
          @db_schema.select { |_, o| o[:db_type] == 'json' }.each_key do |c|
            plugin :serialization, :json, c
            db.log_info "Use JSON serialization on column :#{c}"
          end
        end
      end
    end
  end
end
