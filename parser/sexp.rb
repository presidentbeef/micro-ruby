require_relative 'ast'

module Sexp
  def s type, *args
    AST.const_get(type).new(*args)
  end
end

class AST::Base
  def to_sexp
    sexps = fields.map do |field|
      if field.is_a? AST::Base or field.is_a? AST::BasicTerm
        field.to_sexp
      else
        field.inspect
      end
    end

    sexps.unshift self.class.to_s.gsub(/^AST::/, '').to_sym.inspect
    "s(#{sexps.join(', ')})"
  end
end

class AST::BasicTerm
  def to_sexp
    "s(#{self.class.to_s.gsub(/^AST::/, '').to_sym.inspect})"
  end
end
