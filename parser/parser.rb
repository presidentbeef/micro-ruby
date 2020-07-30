require_relative 'ast'
require_relative 'parselets'
require_relative 'lexer'

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

  def next_token(type = nil)
    token = @tokens.shift

    if type and type != token.type
      raise "Expected `#{type}` token but got `#{token.inspect}`!"
    end

    token
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

  def peek?(token_type)
    @tokens.first.type == token_type
  end

  def register(token_type, parselet)
    @prefix_parselets[token_type] = parselet
  end

  def prefix(token_type)
    @prefix_parselets[token_type] = PrefixOpParselet
  end

  def binary_op(token_type)
    @infix_parselets[token_type] = BinaryOpParselet
  end

  def infix(token_type, parselet)
    @infix_parselets[token_type] = parselet
  end
end

def t(*args)
  Token.new(*args)
end

tokens = [
  Token.new(:if),
  Token.new(:name, 'a'),
  Token.new(:name, 'b'),
  Token.new(:plus),
  Token.new(:name, 'c'),
  Token.new(:name, 'd'),
  Token.new(:else),
  Token.new(:name, 'e'),
  Token.new(:end)
]
p = Parser.new(tokens)
p.binary_op(:plus)
p.binary_op(:gt)
p.prefix(:minus)
p.infix(:dot, DotCallParselet)
p.register(:name, NameParselet)
p.register(:if, IfCondParselet)
p.register(:class, ClassParselet)
p.infix(:lparen, ArgParselet)

require 'pp'
pp p.parse_expression
