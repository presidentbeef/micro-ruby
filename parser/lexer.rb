class Token
  attr_accessor :type
  attr_accessor :text

  def initialize(type, text = nil)
    self.type = type
    self.text = text || self.type
  end
end
