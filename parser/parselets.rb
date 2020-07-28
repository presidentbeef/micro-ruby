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

    then_branch = BlockParser.new.parse(parser, [:else, :elsif, :end])

    case parser.next_token.type
    when :else
      else_branch = BlockParser.new.parse(parser)
      parser.next_token(:end)
    when :elsif
      else_branch = IfCondParselet.new.parse(parser, nil)
    end

    return IfExpression.new(condition, then_branch, else_branch)
  end
end

class ClassParselet
  attr_reader :name, :parent, :body

  def parse(parser, token)
    name = NameParselet.new.parse(parser, parser.next_token(:const))

    if parser.peek.type == :less_than
      parser.next_token
      parent = NameParselet.new.parse(parser, parser.next_token(:const))
    else
      parent = nil
    end

    body = BlockParser.new.parse(parser)

    ClassExpression.new(name, parent, body)
  end
end

class BlockParser
  def parse(parser, end_tokens = [:end])
    be = BlockExpression.new

    until end_tokens.include? parser.peek.type
      be << parser.parse_expression
    end

    be
  end
end
