class NameExpression
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class AssignExpression
  attr_reader :name, :value

  def initialize(name, value)
    @name = name
    @value = value
  end
end

class ConstExpression < NameExpression
end

class PrefixExpression
  attr_reader :op
  attr_reader :operand

  def initialize(op, operand)
    @op = op
    @operand = operand
  end
end

class BinaryOpExpression
  attr_reader :left
  attr_reader :right
  attr_reader :op

  def initialize(left, op, right)
    @left = left
    @op = op
    @right = right
  end
end

class IfExpression
  attr_reader :cond, :then_branch, :else_branch

  def initialize(cond, then_branch, else_branch)
    @cond = cond
    @then_branch = then_branch
    @else_branch = else_branch
  end
end

class BlockExpression
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

class ClassExpression
  attr_reader :name, :parent, :body

  def initialize(name, parent, body)
    @name = name
    @parent = parent
    @body = body
  end
end

class CallExpression
  attr_reader :target, :method, :args

  def initialize(target, method, args = ArgList.new)
    @target = target
    @method = method
    @args = args
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

class Int
  attr_reader :value

  def initialize(value)
    @value = value
  end
end
