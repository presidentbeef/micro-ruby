class Token
  attr_accessor :type
  attr_accessor :text

  def initialize(type, text)
    self.type = type
    self.text = text
  end
end

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
    8
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

class Parser
  def initialize(tokens)
    @tokens = tokens
    @prefix_parselets = {}
    @infix_parselets = {}
  end

  def parse_expression(precedence = 0)
    token = next_token
    prefix_parselet = @prefix_parselets[token.type]

    if prefix_parselet.nil?
      raise "Could not parse #{token.inspect}"
    end

    left = prefix_parselet.parse(self, token)

    while precedence < next_precedence
      token = next_token
      infix = @infix_parselets[token.type]
      left = infix.parse(self, left, token)
    end

    left
  end

  def next_token
    @tokens.shift
  end

  def next_precedence
    token = peek 
    return 0 unless token

    if infix_parselet = @infix_parselets[token.type]
      infix_parselet.precedence(token.type)
    else
      0
    end
  end

  def peek 
    @tokens.first
  end

  def register(token_type, parselet)
    @prefix_parselets[token_type] = parselet
  end

  def prefix(token_type)
    @prefix_parselets[token_type] = PrefixOpParselet.new
  end

  def infix(token_type)
    @infix_parselets[token_type] = BinaryOpParselet.new
  end
end

tokens = [Token.new(:minus, '-'), Token.new(:name, 'a'), Token.new(:plus, '+'), Token.new(:name, 'b')]
p = Parser.new(tokens)
p.prefix(:plus)
p.prefix(:minus)
p.infix(:plus)
p.register(:name, NameParselet.new)

require 'pp'
pp p.parse_expression
