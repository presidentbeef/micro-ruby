Precedence = {
  assign: 1,
  condition: 2,
  plus: 3,
  minus: 3,
  multiply: 4,
  exponent: 5,
  prefix: 6,
  postfix: 7,
  call: 8
}.freeze

class NameParselet
  def parse(parser, token)
    NameExpression.new(token.text)
  end

  def precedence
    Precedence[:call]
  end
end

class PrefixOpParselet
  def parse(parser, token)
    operand = parser.parse_expression(Precedence[token.type])
    PrefixExpression.new(token.type, operand)
  end
end

class BinaryOpParselet
  def parse(parser, left, token)
    right = parser.parse_expression(precedence(token.type))
    BinaryOpExpression.new(left, token.type, right)
  end

  def precedence(op)
    Precedence[op]
  end
end

class IfCondParselet
  def parse(parser, token)
    condition = parser.parse_expression

    next_token = parser.peek

    if next_token.type == :end
      parser.next_token
      return IfExpression.new(condition, nil, nil)
    elsif next_token.type == :else
      parser.next_token
    end

    then_branch = parser.parse_expression

    next_token = parser.peek

    if next_token.type == :end
      parser.next_token
      return IfExpression.new(condition, then_branch, nil)
    elsif next_token.type == :else
      parser.next_token
    else
      raise "Expected 'end' or 'else' but got #{next_token.type}"
    end

    else_branch = parser.parse_expression

    next_token = parser.peek

    if next_token.type != :end
      raise "Expecting an end... but got an #{next_token.type}"
    end

    return IfExpression.new(condition, then_branch, else_branch)
  end
end
