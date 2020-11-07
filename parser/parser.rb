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
    infix(:and, Parselet::And)
    infix(:assign, Parselet::Assign)
    infix(:dot, Parselet::DotCall)
    prefix(:minus)
    infix(:or, Parselet::Or)
    binary_op(:equals)
    binary_op(:gt)
    binary_op(:minus)
    binary_op(:plus)
    register(:begin, Parselet::Begin)
    register(:break, Parselet::BasicValue)
    register(:class, Parselet::Class)
    register(:const, Parselet::Const)
    register(:def, Parselet::Method)
    register(:dstring_start, Parselet::DoubleString)
    register(:false, Parselet::BasicValue)
    register(:if, Parselet::If)
    register(:int, Parselet::Int)
    register(:module, Parselet::Module)
    register(:name, Parselet::Name)
    register(:next, Parselet::BasicValue)
    register(:nil, Parselet::BasicValue)
    register(:not, Parselet::Not)
    register(:rescue, Parselet::Rescue)
    register(:self, Parselet::BasicValue)
    register(:true, Parselet::BasicValue)
    register(:unless, Parselet::Unless)
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
