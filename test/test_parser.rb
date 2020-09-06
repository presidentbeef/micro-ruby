require_relative '../parser/parser'
require_relative '../parser/ast'
require 'minitest/autorun'
require 'minitest/pride'

class TestParserBasics < Minitest::Test
  def assert_parses(input, expected_type = nil)
    parser = Parser.new(Lexer.new(Reader.new(input)))
    ast = parser.parse

    if expected_type
      assert_kind_of expected_type, ast
    end
  end

  def test_and
    assert_parses '1 and 2', AST::And
  end

  def test_or
    assert_parses 'a or b', AST::Or
  end

  def test_not
    assert_parses 'not a', AST::Not
  end

  def test_not_or
    assert_parses 'not a or b', AST::Or
  end

  def test_integer
    assert_parses '1', AST::Int
  end

  def test_plus
    assert_parses '1 + 2', AST::BinaryOp
  end

  def test_minus
    assert_parses '20 - 100', AST::BinaryOp
  end

  def test_assign
    assert_parses 'x = 873', AST::Assign
  end

  def test_dot_call
    assert_parses 'a.b', AST::Call
  end

  def test_dot_call_paren_args
    assert_parses 'a.b(1, 2, x)', AST::Call
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

  def test_class_with_methods
    assert_parses <<~RUBY, AST::Class
    class Test
      def test
        a.b(1)
      end
    end
    RUBY
  end

  def test_const
    assert_parses 'CONST', AST::Const
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

  def test_nil
    assert_parses 'nil', AST::Nil
  end

  def test_true
    assert_parses 'true', AST::True
  end

  def test_false
    assert_parses 'false', AST::False
  end

  def test_self
    assert_parses 'self', AST::Self
  end

  def test_self_call
    assert_parses 'self.something(1)', AST::Call
  end
end
