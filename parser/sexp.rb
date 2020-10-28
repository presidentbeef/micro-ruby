require_relative 'ast'

module Sexp
  def s type, *args
    klass = AST.const_get(type)

    if klass < AST::Base
      klass.new(*args)
    elsif klass < AST::BasicTerm
      klass.new(klass) # TODO: token?
    else
      raise "Unexpected AST type: #{klass.inspect}"
    end
  end
end

class AST::Base
  def to_sexp
    sexps = fields.map do |field|
      if field.is_a? AST::Base or field.is_a? AST::BasicTerm
        field.to_sexp
      elsif field.is_a? Array
        "[#{field.map(&:to_sexp).join(', ')}]"
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
