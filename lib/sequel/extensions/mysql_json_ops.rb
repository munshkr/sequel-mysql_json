module Sequel
  module Mysql
    # The JSONOp class is a simple container for a single object that defines
    # methods that yield Sequel expression objects representing MySQL json
    # operators and functions.
    #
    # In the method documentation examples, assume that:
    #
    #   json_op = Sequel.mysql_json(:json)
    class JSONOp < Sequel::SQL::Wrapper
      # Extract a value as json.
      #
      #   json_op['$[0]'] # json_extract(json, '$[0]')
      #   json_op['$.a'] # json_extract(json, '$.a')
      def [](path)
        json_op(:extract, path)
      end
      alias get []
      alias extract []

      # Replace values for paths that exist and add values
      # for paths that do not exist.
      #
      def set(*args)
        json_op(:set, *args)
      end

      # Add new values but does not replace existing values
      #
      def insert(*args)
        json_op(:insert, *args)
      end

      # Replace existing values and ignore new values
      #
      def replace(*args)
        json_op(:replace, *args)
      end

      # Take a JSON document and one or more paths that specify values
      # to be removed from the document.
      #
      def remove(*args)
        json_op(:remove, *args)
      end

      # Take two or more JSON documents and return the combined result
      #
      def merge(*args)
        json_op(:merge, *args)
      end

      # Return the value's JSON type if it is valid and produces an error
      # otherwise.
      #
      def type
        Sequel::SQL::StringExpression.new(:NOOP, function(:type))
      end

      private

      # Return a function wrapped in a JSONOp object
      def json_op(*args)
        self.class.new(function(*args))
      end

      # Return a function with the given name, and the receiver as the first
      # argument, with any additional arguments given.
      def function(name, *args)
        SQL::Function.new(function_name(name), self, *args)
      end

      # The json type functions are prefixed with json_
      def function_name(name)
        "json_#{name}"
      end
    end

    module JSONOpMethods
      # Wrap the receiver in an JSONOp so you can easily use the MySQL
      # json functions and operators with it.
      def mysql_json_op
        JSONOp.new(self)
      end
    end
  end

  module SQL::Builders
    # Return the object wrapped in an Mysql::JSONOp.
    def mysql_json_op(v)
      case v
      when Mysql::JSONOp
        v
      else
        Mysql::JSONOp.new(v)
      end
    end
  end

  class SQL::GenericExpression
    include Sequel::Mysql::JSONOpMethods
  end

  class LiteralString
    include Sequel::Mysql::JSONOpMethods
  end
end

# :nocov:
if Sequel.core_extensions?
  class Symbol
    include Sequel::Mysql::JSONOpMethods
  end
end

if defined?(Sequel::CoreRefinements)
  module Sequel::CoreRefinements
    refine Symbol do
      include Sequel::Mysql::JSONOpMethods
    end
  end
end
# :nocov:
