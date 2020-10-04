require_relative '../parser/ast'
require 'minitest/autorun'
require 'minitest/pride'

class TestAST < Minitest::Test
  class Example < AST::Base
    fields :a, :b, :c
  end

  def test_equality
    e1 = Example.new('a', 'b', 'c')
    e2 = Example.new('a', 'b', 'c')

    assert_equal e1, e2
  end

  def test_field_names
    expected = [:a, :b, :c]

    assert_equal expected, Example.field_names
  end

  def test_fields
    expected = ['a', 'b', 'c']
    example = Example.new('a', 'b', 'c')

    assert_equal expected, example.fields
  end
end
