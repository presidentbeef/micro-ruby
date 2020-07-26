class Token
  attr_accessor :type
  attr_accessor :text

  def initialize(type, text)
    self.type = type
    self.text = text
  end
end
