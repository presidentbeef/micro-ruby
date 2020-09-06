module Parselet
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

  class And
    def self.parse(parser, left, token)
      right = parser.parse_expression(Precedence[:and_or])

      case token.type
      when :and
        AST::And.new(left, right)
      when :or
        AST::Or.new(left, right)
      else
        raise "Unknown token type: #{token} instead of and/or"
      end
    end

    def self.precedence(*)
      Precedence[:and_or]
    end
  end

  Or = And

  class Assign
    def self.parse(parser, left, token)
      right = parser.parse_expression(0)

      unless left.is_a? AST::Name
        raise "Cannot assign to anything but a name: #{left.inspect}"
      end

      AST::Assign.new(left, right)
    end

    def self.precedence(*)
      Precedence[:assign]
    end
  end

  class Class
    attr_reader :name, :parent, :body

    def self.parse(parser, token)
      name = Name.parse(parser, parser.next_token(:const))

      if parser.peek.type == :lt
        parser.next_token
        parent = Name.parse(parser, parser.next_token(:const))
      else
        parent = nil
      end

      body = BlockParser.parse(parser)
      parser.next_token(:end)

      AST::Class.new(name, parent, body)
    end
  end

  class Const
    def self.parse(parser, token)
      AST::Const.new(token.text)
    end

    def self.precedence(*)
      Precedence[:call]
    end
  end

  class Method
    def self.parse(parser, token)
      name = parser.next_token(:name)

      if parser.peek? :lparen
        parser.next_token(:lparen)
        params = ArgParser.parse(parser)
      end

      body = BlockParser.parse(parser)
      parser.next_token(:end)

      AST::Method.new(name, params, body)
    end
  end

  class DotCall
    def self.parse(parser, left, token)
      name = parser.next_token(:name)
      if parser.peek? :lparen
        parser.next_token(:lparen)
        args = ArgParser.parse(parser)

        AST::Call.new(left, name, args)
      else
        AST::Call.new(left, right)
      end
    end

    def self.precedence(_)
      Precedence[:call]
    end
  end

  class IfCond
    def self.parse(parser, token)
      condition = parser.parse_expression

      then_branch = BlockParser.parse(parser, [:else, :elsif, :end])

      case parser.next_token.type
      when :else
        else_branch = BlockParser.parse(parser)
        parser.next_token(:end)
      when :elsif
        else_branch = IfCond.parse(parser, nil)
      end

      return AST::If.new(condition, then_branch, else_branch)
    end
  end

  class Int
    def self.parse(parser, token)
      AST::Int.new(token.text.to_i)
    end
  end

  class Module
    attr_reader :name, :body

    def self.parse(parser, token)
      name = Name.parse(parser, parser.next_token(:const))

      body = BlockParser.parse(parser)
      parser.next_token(:end)

      AST::Module.new(name, body)
    end
  end

  class Name
    def self.parse(parser, token)
      AST::Name.new(token.text)
    end

    def self.precedence(*)
      Precedence[:call]
    end
  end

  class Not
    def self.parse(parser, token)
      expr = parser.parse_expression(Precedence[:and_or])

      AST::Not.new(expr)
    end
  end

  class Or
  end

  # Helper / Generic Parselets

  class PrefixOp
    def self.parse(parser, token)
      operand = parser.parse_expression(Precedence[:unary])
      AST::Prefix.new(token.type, operand)
    end
  end

  class BinaryOp
    def self.parse(parser, left, token)
      right = parser.parse_expression(precedence(token.type))
      AST::BinaryOp.new(left, token.type, right)
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

  # Helper to parse a block of expressions
  # into an array of expressions
  class BlockParser
    def self.parse(parser, end_tokens = [:end])
      be = AST::Block.new

      until end_tokens.include? parser.peek.type
        be << parser.parse_expression
      end

      be
    end
  end

  # Will need to split this at some point to deal
  # with formal parameters vs arguments
  class ArgParser
    def self.parse(parser)
      args = AST::ArgList.new

      next_arg(args, parser)

      while parser.peek? :comma
        parser.next_token(:comma)
        next_arg(args, parser)
      end

      parser.next_token(:rparen)

      args
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

  class BasicValue
    def self.parse(parser, token)
      case token.text
      when :nil
        AST::Nil.new(token)
      when :true
        AST::True.new(token)
      when :false
        AST::False.new(token)
      else
        raise "Unknown value: #{token}"
      end
    end
  end
end
