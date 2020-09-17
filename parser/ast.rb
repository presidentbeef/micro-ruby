module AST
  class And
    attr_reader :left, :right

    def initialize(left, right)
      @left = left
      @right = right
    end
  end

  class Assign
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end
  end

  # Basic class for ASTs with fixed values
  class BasicTerm
    def initialize(token)
    end
  end

  class Class
    attr_reader :name, :parent, :body

    def initialize(name, parent, body)
      @name = name
      @parent = parent
      @body = body
    end
  end

  class Call
    attr_reader :target, :method, :args, :block

    def initialize(target, method, args, block)
      @target = target
      @method = method
      @args = args
      @block = block
    end
  end

  class DoBlock
    attr_reader :args, :block

    def initialize(args, block)
      @args = args
      @block = block
    end
  end

  class DoubleString
    attr_reader :string

    def initialize(string)
      @string = string
    end
  end

  class Name
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class Const < Name
  end

  class False < BasicTerm
  end

  class If
    attr_reader :cond, :then_branch, :else_branch

    def initialize(cond, then_branch, else_branch)
      @cond = cond
      @then_branch = then_branch
      @else_branch = else_branch
    end
  end

  class Int
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class Method
    attr_reader :name, :params, :body

    def initialize(name, params, body)
      @name = name
      @params = params
      @body = body
    end
  end

  class Module
    attr_reader :name, :body

    def initialize(name, body)
      @name = name
      @body = body
    end
  end

  class Nil < BasicTerm
  end

  class Not
    attr_reader :expr

    def initialize(expr)
      @expr = expr
    end
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

  class Prefix
    attr_reader :op, :operand

    def initialize(op, operand)
      @op = op
      @operand = operand
    end
  end

  class BinaryOp
    attr_reader :left
    attr_reader :right
    attr_reader :op

    def initialize(left, op, right)
      @left = left
      @op = op
      @right = right
    end
  end

  class ArgList
    attr_reader :args

    def initialize
      @args = []
    end

    def << arg
      @args << arg
    end
  end

  class Block
    attr_reader :exps

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
