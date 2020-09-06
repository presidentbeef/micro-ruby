# frozen_string_literal: true

class Token
  attr_accessor :type, :text, :pos

  def initialize(type, text = nil, pos = nil)
    self.type = type
    self.text = text || self.type
    self.pos = pos
  end
end

Keywords = %w[
  and
  begin
  break
  case
  class
  def
  do
  else
  end
  ensure
  false
  if
  module
  next
  nil
  not
  or
  rescue
  return
  self
  super
  true
  unless
  until
  when
  while
  yield
]

class Reader
  def initialize(input_string)
    @str = input_string
    reset
  end

  def next_rune
    return nil if @pos >= @str.length

    @last_rune = @str[@pos]
    @pos += 1
    @last_rune
  end

  def back
    @pos -= 1
  end

  def reset
    @pos = 0
    @last_rune = nil
  end
end

class Lexer
  def initialize(reader)
    @reader = reader
  end

  def peek
    if @cache
      return @cache
    else
      nt = next_token
      @cache = nt
      nt
    end
  end

  def empty?
    peek.type == :eof
  end

  def next_token
    if @cache
      t = @cache
      @cache = nil
      return t
    end

    loop do
      r = @reader.next_rune

      if r.nil?
        return Token.new(:eof, nil)
      end

      case r
      when "\n"
        reset_line
        next
      when '+'
        return Token.new(:plus, '+')
      when '-'
        return Token.new(:minus, '-')
      when '*'
        return Token.new(:prod, '*')
      when '/'
        return Token.new(:div, '/')
      when '>'
        return Token.new(:gt, '>')
      when '<'
        return Token.new(:lt, '<')
      when '='
        return Token.new(:assign, '=')
      when '.'
        return Token.new(:dot)
      when '('
        return Token.new(:lparen)
      when ')'
        return Token.new(:rparen)
      when ','
        return Token.new(:comma)
      when /\s/
        next
      when /[0-9]/
        return lex_int(r)
      when /[a-zA-Z]/
        return lex_name(r)
      else
        raise "Unexpected character: `#{r}`"
      end
    end
  end

  def lex_int(first_digit)
    int = first_digit.dup

    loop do
      i = @reader.next_rune

      if i.nil?
        return Token.new(:int, int)
      elsif i.match?(/[0-9]/)
        int << i
      else
        @reader.back
        return Token.new(:int, int)
      end
    end
  end

  def lex_name(first_char)
    name = first_char.dup

    loop do
      c = @reader.next_rune

      if c and c.match?(/[a-zA-Z0-9_]/)
        name << c
      else
        @reader.back unless c.nil?

        if Keywords.include? name
          return Token.new(name.to_sym)
        elsif name.match?(/^[A-Z]/)
          return Token.new(:const, name)
        else
          return Token.new(:name, name)
        end
      end
    end
  end

  def reset_line
  end

  def reset
    @cache = nil
    @line = 1
    @col = 1
    @reader.reset
  end

  def all
    tokens = []
    while not empty?
      tokens << next_token
    end
    tokens
  end
end
