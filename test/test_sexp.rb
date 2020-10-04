require_relative '../parser/sexp'
require_relative '../parser/lexer'
require 'minitest/autorun'
require 'minitest/pride'

class TestSexp < Minitest::Test
  include Sexp

  def test_sexp_roundtrip
    example = AST::And.new(AST::Int.new(1), AST::Int.new(2))
    sexp = example.to_sexp
    result = eval(sexp)

    assert_equal example, result
  end

  def test_ast_base_to_sexp
    const = AST::Const.new('HELLO').to_sexp
    expected = 's(:Const, "HELLO")'

    assert_equal expected, const
  end

  def test_ast_basic_term_to_sexp
    true_sexp = AST::True.new(Token.new('true')).to_sexp
    expected = 's(:True)'

    assert_equal expected, true_sexp
  end
end
