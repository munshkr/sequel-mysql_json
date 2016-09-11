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

      # Append values to the end of the indicated arrays within a JSON document
      # and return the result.
      #
      def array_append(*args)
        json_op(:array_append, self, *path_value_args(args))
      end

      # Update a JSON document, inserting into an array within the document and
      # returning the modified document.
      #
      def array_insert(*args)
        json_op(:array_insert, self, *path_value_args(args))
      end

      # Return true or false whether a specific +value+ is contained in a
      # target JSON document.
      #
      # If a +path+ argument is given, check at a specific path within the
      # target document.
      #
      def contains(val, path=nil)
        fn = function(:contains, self, Sequel.object_to_json(val), path)
        Sequel::SQL::BooleanExpression.new(:NOOP, fn)
      end

      # Return whether a JSON document contains data at a given path or paths
      #
      # Returns false if no specified path exists within the document.
      # Otherwise, the return value depends on the +one_or_all+ argument:
      #
      #  * one: true if at least one path exists within the document
      #  * all: true if all paths exist within the document
      #
      def contains_path(one_or_all, *paths)
        fn = json_op(:contains_path, self, one_or_all.to_s, *paths)
        Sequel::SQL::BooleanExpression.new(:NOOP, fn)
      end

      # Return the maximum depth of a JSON document
      #
      def depth
        Sequel::SQL::NumericExpression.new(:NOOP, function(:depth, self))
      end

      # Return data from a JSON document, selected from the parts of the
      # document matched by the path arguments.
      #
      #   json_op.extract('[0]')   # JSON_EXTRACT(json, '$[0]')
      #   json_op.extract('.a')    # JSON_EXTRACT(json, '$.a')
      #
      # When using an Integer, it will be used as an array index of a JSON array
      #
      #   json_op.extract(0)        # JSON_EXTRACT(json, '$[0]')
      #
      # When using a Symbol, it will be used as a property name of a JSON object
      #
      #   json_op.extract(:a)       # JSON_EXTRACT(json, '$.a')
      #
      def extract(key)
        case value
        when SQL::Function
          # Merge path expression of a nested :extract function
          json_op, path = value.args
          json_op(:extract, json_op, path + path_expression(key))
        else
          json_op(:extract, self, "$#{path_expression(key)}")
        end
      end
      alias :[]  :extract
      alias :get :extract

      # Insert data into a JSON document and return the result
      #
      def insert(*args)
        json_op(:insert, self, *path_value_args(args))
      end

      # Return the keys from the top-level value of a JSON object as a JSON array
      #
      # If a +path+ argument is given, the top-level keys from the selected path. 
      #
      def keys(path=nil)
        json_op(:keys, self, path)
      end

      # Return the length of JSON document
      #
      # If a +path+ argument is given, the length of the value within the
      # document identified by the path.
      #
      def length(path=nil)
        Sequel::SQL::NumericExpression.new(:NOOP, function(:length, self, path))
      end

      # Merges two or more JSON documents and returns the merged result
      #
      def merge(*docs)
        json_op(:merge, self, *docs.map { |d| Sequel.object_to_json(d) })
      end

      # Take a JSON document and one or more paths that specify values
      # to be removed from the document.
      #
      def remove(*paths)
        json_op(:remove, self, *paths)
      end

      # Replace existing values and ignore new values
      #
      def replace(*args)
        json_op(:replace, self, *path_value_args(args))
      end

      # Returns the path to the given string within a JSON document
      #
      def search(one_or_all, search_str, escape_char=nil, *paths)
        json_op(:search, self, one_or_all.to_s, search_str, escape_char, *paths)
      end

      # Replace values for paths that exist and add values
      # for paths that do not exist.
      #
      def set(*args)
        json_op(:set, self, *path_value_args(args))
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

      # Return a path expression based on key class
      def path_expression(key)
        case key
        when Integer
          "[#{key}]"
        when Symbol
          ".#{key_name(key)}"
        else
          key
        end
      end

      # Return double quoted key name if it has spaces
      def key_name(key)
        key.to_s.index(SPACE_RE) ? "\"#{key}\"" : key
      end

      # Serialize literal values from a flattened (path, value) pairs array
      def path_value_args(args)
        args.each_slice(2)
          .map { |p, v| [p, serialize_literal(v)] }.flatten(1)
      end

      # Serialize a Ruby value into a MySQL json literal
      #
      # Arrays and hashes are written as JSON_ARRAY and JSON_OBJECT function
      # calls.
      #
      def serialize_literal(value)
        case value
        when NilClass, FalseClass, TrueClass, String, Numeric
          value
        when Symbol
          value.to_s
        when Array
          function(:array, *value.map { |v| serialize_literal(v) })
        when Hash
          function(:object, *value.map { |k, v| [k.to_s, serialize_literal(v)] }.flatten(1))
        else
          Sequel.object_to_json(value)
        end
      end
    end

    module JSONOpMethods
      # Wrap the receiver in an JSONOp so you can easily use the MySQL
      # json functions and operators with it.
      def mysql_json_op
        case self
        when Hash, Array
          JSONOp.new(Sequel.object_to_json(self))
        else
          JSONOp.new(self)
        end
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

  class Hash
    include Sequel::Mysql::JSONOpMethods
  end

  class Array
    include Sequel::Mysql::JSONOpMethods
  end
end

if defined?(Sequel::CoreRefinements)
  module Sequel::CoreRefinements
    refine Symbol do
      include Sequel::Mysql::JSONOpMethods
    end

    refine Hash do
      include Sequel::Mysql::JSONOpMethods
    end

    refine Array do
      include Sequel::Mysql::JSONOpMethods
    end
  end
end
# :nocov:
