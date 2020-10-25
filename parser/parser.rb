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
    infix(:assign, Parselet::Assign)
    infix(:dot, Parselet::DotCall)
    infix(:and, Parselet::And)
    infix(:or, Parselet::Or)
    prefix(:minus)
    binary_op(:plus)
    binary_op(:gt)
    binary_op(:minus)
    binary_op(:equals)
    register(:class, Parselet::Class)
    register(:const, Parselet::Const)
    register(:if, Parselet::If)
    register(:unless, Parselet::Unless)
    register(:int, Parselet::Int)
    register(:module, Parselet::Module)
    register(:name, Parselet::Name)
    register(:def, Parselet::Method)
    register(:nil, Parselet::BasicValue)
    register(:true, Parselet::BasicValue)
    register(:false, Parselet::BasicValue)
    register(:self, Parselet::BasicValue)
    register(:not, Parselet::Not)
    register(:dstring_start, Parselet::DoubleString)
    register(:begin, Parselet::Begin)
  end

  def parse
    ast = Parselet::BlockParser.parse(self, [:eof])
    if ast.exps.count == 1
      ast.exps.first
    else
      ast
    end
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
    @prefix_parselets[token_type] = Parselet::PrefixOp
  end

  def binary_op(token_type)
    @infix_parselets[token_type] = Parselet::BinaryOp
  end

  def infix(token_type, parselet)
    @infix_parselets[token_type] = parselet
  end
end
