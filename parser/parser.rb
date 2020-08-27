require_relative 'ast'
require_relative 'parselets'
require_relative 'lexer'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @prefix_parselets = {}
    @infix_parselets = {}
    initialize_parselets
  end

  def initialize_parselets
    infix(:assign, AssignParselet)
    infix(:dot, DotCallParselet)
    infix(:lparen, ArgParselet)
    prefix(:minus)
    binary_op(:plus)
    binary_op(:gt)
    binary_op(:minus)
    register(:class, ClassParselet)
    register(:const, ConstParselet)
    register(:if, IfCondParselet)
    register(:int, IntParselet)
    register(:module, ModuleParselet)
    register(:name, NameParselet)
  end

  def parse
    ast = parse_expression

    unless @tokens.empty?
      raise "Didn't finish parsing. Stopped at #{@tokens.peek.inspect}"
    end

    ast
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
    token = @tokens.next_token

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
    @tokens.peek
  end

  def peek?(token_type)
    @tokens.peek.type == token_type
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
