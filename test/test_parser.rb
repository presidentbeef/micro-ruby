require_relative '../parser/parser'
require_relative '../parser/ast'
require_relative '../parser/sexp'
require 'minitest/autorun'
require 'minitest/pride'

class TestParserBasics < Minitest::Test
  include Sexp

  def assert_parses(input, expected_type = nil)
    lexer = Lexer.new(Reader.new(input))
    parser = Parser.new(lexer)
    ast = parser.parse

    if expected_type.is_a? Class
      assert_kind_of expected_type, ast
    else
      assert_equal ast, expected_type
    end
  end

  def test_and
    assert_parses '1 and 2', s(:And, s(:Int, 1), s(:Int, 2))
  end

  def test_or
    assert_parses 'a or b', s(:Or, s(:Name, 'a'), s(:Name, 'b'))
  end

  def test_not
    assert_parses 'not a', s(:Not, s(:Name, 'a'))
  end

  def test_not_or
    assert_parses 'not a or b', s(:Or,
                                  s(:Not,
                                    s(:Name, "a")),
                                    s(:Name, "b"))
  end

  def test_integer
    assert_parses '1', s(:Int, 1)
  end

  def test_plus
    assert_parses '1 + 2', s(:BinaryOp,
                             s(:Int, 1),
                             :plus,
                             s(:Int, 2))
  end

  def test_minus
    assert_parses '20 - 100', s(:BinaryOp,
                                s(:Int, 20),
                                :minus,
                                s(:Int, 100))
  end

  def test_assign
    assert_parses 'x = 873', s(:Assign,
                               s(:Name, 'x'),
                               s(:Int, 873))
  end

  def test_equals
    assert_parses 'x == 873', s(:BinaryOp,
                                s(:Name, 'x'),
                                :equals,
                                s(:Int, 873))
  end

  def test_dot_call
    assert_parses 'a.b', AST::Call
  end

  def test_dot_call_paren_args
    assert_parses 'a.b(1, 2, x)', AST::Call
  end

  def test_chained_call
    assert_parses 'a.b.c', AST::Call
  end

  def test_dot_call_do_block
    assert_parses <<~RUBY, AST::Call
    a.b do |x, y|
      c
    end
    RUBY
  end

  def test_class
    assert_parses <<~RUBY, AST::Class
    class TestClass
    end
    RUBY
  end

  def test_class_inheritance
    assert_parses <<~RUBY, AST::Class
    class Test < Test2
    end
    RUBY
  end

  def test_module
    assert_parses <<~RUBY, AST::Module
    module TestModule
    end
    RUBY
  end

  def test_def_method
    assert_parses <<~RUBY, AST::Method
    def a(x)
    end
    RUBY
  end

  def test_def_method_no_args
    assert_parses <<~RUBY, AST::Method
    def a
    end
    RUBY
  end

  def test_class_with_methods
    assert_parses <<~RUBY, AST::Class
    class Test
      def test
        a.b(1)
      end

      def test2
        1
        "2"
      end
    end
    RUBY
  end

  def test_const
    assert_parses 'CONST', s(:Const, 'CONST')
  end

  def test_if
    assert_parses <<~RUBY, AST::If
    if something
      this
    elsif nothing
      that
    else
      other
      thing
    end
    RUBY
  end

  def test_unless
    assert_parses <<~RUBY, AST::Unless
    unless something
      blah
    end
    RUBY
  end

  def test_unless_else
    assert_parses <<~RUBY, AST::Unless
    unless something
      this
      thing
    else
      that
      thing
    end
    RUBY
  end

  def test_nil
    assert_parses 'nil', s(:Nil)
  end

  def test_true
    assert_parses 'true', s(:True)
  end

  def test_false
    assert_parses 'false', s(:False)
  end

  def test_self
    assert_parses 'self', s(:Self)
  end

  def test_self_call
    assert_parses 'self.something(1)', AST::Call
  end

  def test_self_method
    assert_parses "def self.x\nend", AST::SelfMethod
  end

  def test_double_string
    assert_parses '""', s(:DoubleString, '')
    assert_parses '"hello world"', s(:DoubleString, 'hello world')
    assert_parses '"goodbye\" world"', s(:DoubleString, "goodbye\\\" world")
  end

  def test_more_than_one_expression
    assert_parses <<~RUBY, AST::Block
    x = a.b(1)
    if x == 1
      yikes
      oops
    end
    RUBY
  end

  def test_begin_simple
    assert_parses <<~RUBY, AST::BeginBlock
    begin
      1
      2
    end
    RUBY
  end

  def test_begin_simple_rescue
    ast = s(:BeginBlock,
            s(:Block,
              [
                s(:Name, "a"),
                s(:Name, "b")
              ]
             ),
             [
               s(:Rescue,
                 s(:Block,
                   [
                     s(:Name, "d")
                   ]),
             nil, nil)
             ],
             nil, nil)

    assert_parses <<~RUBY, ast
    begin
      a
      b
    rescue
      d
    end
    RUBY
  end

  def test_begin_rescue
    ast = s(:BeginBlock,
            s(:Block, [s(:Int, 1), s(:Int, 2)]),
            [s(:Rescue, s(:Block, [s(:Int, 3)]),
               nil,
               s(:Name, "e"))],
            nil, nil)

    assert_parses <<~RUBY, ast
    begin
      1
      2
    rescue => e
      3
    end
    RUBY
  end

  def test_begin_rescue_ensure_else
    ast = s(:BeginBlock,
            s(:Block, [s(:Int, 1)]),
            [s(:Rescue, s(:Block, [s(:Int, 3)]), nil, s(:Name, "e"))], # rescue
            s(:Block, []), # ensure
            s(:Block, [])) # else

    assert_parses <<~RUBY, ast
    begin
      1
    rescue => e
      3
    ensure
    else
    end
    RUBY
  end

  def test_break
    assert_parses 'break', AST::Break
  end
end
