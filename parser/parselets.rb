Precedence = {
  assign: 1,
  and_or: 2,
  equality: 3,
  compare: 4,
  term: 5,
  product: 6,
  unary: 7,
  call: 8
}.freeze

class NameParselet
  def self.parse(parser, token)
    NameExpression.new(token.text)
  end

  def self.precedence
    Precedence[:call]
  end
end

class PrefixOpParselet
  def self.parse(parser, token)
    operand = parser.parse_expression(Precedence[:unary])
    PrefixExpression.new(token.type, operand)
  end
end

class BinaryOpParselet
  def self.parse(parser, left, token)
    right = parser.parse_expression(precedence(token.type))
    BinaryOpExpression.new(left, token.type, right)
  end

  def self.precedence(op)
    case op
    when :plus, :minus
      Precedence[:term]
    when :prod, :div
      Precedence[:product]
    when :gt, :lt
      Precedence[:compare]
    when :equal
      Precedence[:equality]
    else
      raise "Unknown operator: #{op}"
    end
  end
end

class DotCallParselet
  def self.parse(parser, left, token)
    right = parser.parse_expression(precedence(token))
    CallExpression.new(left, right)
  end

  def self.precedence(_)
    Precedence[:call]
  end
end

class IfCondParselet
  def self.parse(parser, token)
    condition = parser.parse_expression

    then_branch = BlockParser.parse(parser, [:else, :elsif, :end])

    case parser.next_token.type
    when :else
      else_branch = BlockParser.parse(parser)
      parser.next_token(:end)
    when :elsif
      else_branch = IfCondParselet.parse(parser, nil)
    end

    return IfExpression.new(condition, then_branch, else_branch)
  end
end

class ClassParselet
  attr_reader :name, :parent, :body

  def self.parse(parser, token)
    name = NameParselet.parse(parser, parser.next_token(:const))

    if parser.peek.type == :less_than
      parser.next_token
      parent = NameParselet.parse(parser, parser.next_token(:const))
    else
      parent = nil
    end

    body = BlockParser.parse(parser)

    ClassExpression.new(name, parent, body)
  end
end

class BlockParser
  def self.parse(parser, end_tokens = [:end])
    be = BlockExpression.new

    until end_tokens.include? parser.peek.type
      be << parser.parse_expression
    end

    be
  end
end
