module AST
  # Base class for AST
  class Base
    # Set field names
    def self.fields(*args)
      attr_reader(*args)
      @field_names = args.freeze
    end

    def self.field_names
      @field_names
    end

    # Ensures class names are inherited
    def self.inherited(klass)
      if self.class != Base
        klass.fields(*@field_names)
      end
    end

    # Set up the class by mapping arguments to fields
    def initialize(*args)
      self.class.field_names.each_with_index do |field, i|
        if i > args.count
          raise ArgumentError, "No value provided for field `#{field}`"
        end

        instance_variable_set(:"@#{field}", args[i])
      end
    end
  end

  # Basic class for ASTs with fixed values
  class BasicTerm
    def initialize(token)
    end
  end

  class And < Base
    fields :left, :right
  end

  class Assign < Base
    fields :name, :value
  end

  class Class < Base
    fields :name, :parent, :body
  end

  class Call < Base
    fields :target, :method, :args, :block
  end

  class DoBlock < Base
    fields :args, :block
  end

  class DoubleString < Base
    fields :string
  end

  class Name < Base
    fields :name
  end

  class Const < Name
  end

  class False < BasicTerm
  end

  class If < Base
    fields :cond, :then_branch, :else_branch
  end

  class Int < Base
    fields :value
  end

  class Method < Base
    fields :name, :params, :body
  end

  class Module < Base
    fields :name, :body
  end

  class Nil < BasicTerm
  end

  class Not < Base
    fields :expr
  end

  class Or < And
  end

  class Self < BasicTerm
  end

  class SelfMethod < Method
  end

  class True < BasicTerm
  end

  class Unless < If
  end

  # Generic / Helper ASTs

  class Prefix < Base
    fields :op, :operand
  end

  class BinaryOp < Base
    fields :left, :op, :right
  end

  class ArgList < Base
    fields :args

    def initialize
      @args = []
    end

    def << arg
      @args << arg
    end
  end

  class Block < Base
    fields :exps

    def initialize
      @exps = []
    end

    def << exp
      @exps << exp
    end

    def empty?
      @exps.empty?
    end
  end
end
