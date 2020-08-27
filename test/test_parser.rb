require_relative '../parser/parser'
require 'minitest/autorun'
require 'minitest/pride'

class TestParserBasics < Minitest::Test
  def assert_parses(input)
    parser = Parser.new(Lexer.new(Reader.new(input)))
    parser.parse
  end

  def test_integer
    assert_parses '1'
  end

  def test_plus
    assert_parses '1 + 2'
  end

  def test_minus
    assert_parses '20 - 100'
  end

  def test_assign
    assert_parses 'x = 873'
  end

  def test_dot_call
    assert_parses 'a.b'
  end

  def test_dot_call_paren_args
    assert_parses 'a.b(1, 2, x)'
  end

  def test_class
    assert_parses <<~RUBY
    class TestClass
    end
    RUBY
  end

  def test_module
    assert_parses <<~RUBY
    module TestModule
    end
    RUBY
  end

  def test_const
    assert_parses 'CONST'
  end

  def test_if
    assert_parses <<~RUBY
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
end
