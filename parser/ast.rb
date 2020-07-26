class NameExpression
  attr_reader :name

  def initialize(name)
    @name = name
  end
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
