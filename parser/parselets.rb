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

  def self.precedence(*)
    Precedence[:call]
  end
end

class ConstParselet
  def self.parse(parser, token)
    ConstExpression.new(token.text)
  end

  def self.precedence(*)
    Precedence[:call]
  end
end

class AssignParselet
  def self.parse(parser, left, token)
    right = parser.parse_expression(0)

    unless left.is_a? NameExpression
      raise "Cannot assign to anything but a name: #{left.inspect}"
    end

    AssignExpression.new(left, right)
  end

  def self.precedence(*)
    Precedence[:assign]
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

class ArgParselet
  def self.parse(parser, left, token)
    args = ArgList.new

    next_arg(args, parser)

    while parser.peek? :comma
      parser.next_token(:comma)
      next_arg(args, parser)
    end

    parser.next_token

    CallExpression.new(nil, left, args)
  end

  def self.next_arg(args, parser)
    unless parser.peek? :rparen
      args << parser.parse_expression(precedence(self))
    end
  end

  def self.precedence(_)
    1
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

    if parser.peek.type == :lt
      parser.next_token
      parent = NameParselet.parse(parser, parser.next_token(:const))
    else
      parent = nil
    end

    body = BlockParser.parse(parser)
    parser.next_token(:end)

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

class IntParselet
  def self.parse(parser, token)
    Int.new(token.text.to_i)
  end
end
