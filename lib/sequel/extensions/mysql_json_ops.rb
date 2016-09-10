module Sequel
  module Mysql
    # The JSONOp class is a simple container for a single object that defines
    # methods that yield Sequel expression objects representing MySQL json
    # operators and functions.
    #
    # In the method documentation examples, assume that:
    #
    #   json_op = Sequel.mysql_json_op(:json)
    #
    class JSONOp < Sequel::SQL::Wrapper
      SPACE_RE = /\s+/

      # Extract a value as json
      #
      #   json_op.extract('[0]')   # JSON_EXTRACT(json, '$[0]')
      #   json_op.extract('.a')    # JSON_EXTRACT(json, '$.a')
      #
      # When using an Integer, it will be used as an index of a JSON array
      #
      #   json_op.extract(0)        # JSON_EXTRACT(json, '$[0]')
      #
      # When using a Symbol, it will be used as a member of a JSON object
      #
      #   json_op.extract(:a)       # JSON_EXTRACT(json, '$.a')
      #
      def extract(key)
        case value
        when SQL::Function
          # Merge path selector of a nested :extract function
          json_op, path = value.args
          json_op(:extract, json_op, path + path_selector(key))
        else
          json_op(:extract, self, "$#{path_selector(key)}")
        end
      end
      alias :[]  :extract
      alias :get :extract

      # Replace values for paths that exist and add values
      # for paths that do not exist.
      #
      def set(*args)
        json_op(:set, self, *args)
      end

      # Add new values but does not replace existing values
      #
      def insert(*args)
        json_op(:insert, self, *args)
      end

      # Replace existing values and ignore new values
      #
      def replace(*args)
        json_op(:replace, self, *args)
      end

      # Take a JSON document and one or more paths that specify values
      # to be removed from the document.
      #
      def remove(*args)
        json_op(:remove, self, *args)
      end

      # Take two or more JSON documents and return the combined result
      #
      def merge(*args)
        json_op(:merge, self, *args)
      end

      # Return the value's JSON type if it is valid and produces an error
      # otherwise.
      #
      def type
        Sequel::SQL::StringExpression.new(:NOOP, function(:type, self))
      end

      private

      # Return a function wrapped in a JSONOp object
      def json_op(*args)
        self.class.new(function(*args))
      end

      # Return a function with the given name, and the receiver as the first
      # argument, with any additional arguments given.
      def function(name, *args)
        SQL::Function.new(function_name(name), *args)
      end

      # The json type functions are prefixed with JSON_
      def function_name(name)
        "JSON_#{name.to_s.upcase}"
      end

      # Return a path selector based on key class
      def path_selector(key)
        case key
        when Integer
          "[#{key}]"
        when Symbol
          ".#{quote(key)}"
        else
          key
        end
      end

      # Return quoted key if it has spaces
      def quote(key)
        key.to_s.index(SPACE_RE) ? "\"#{key}\"" : key
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
