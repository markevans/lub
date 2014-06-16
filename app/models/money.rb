# encoding: utf-8
class Money
  include ActionView::Helpers::NumberHelper

  def initialize(pence)
    @pence = pence
  end

  attr_reader :pence

  def + other
    self.class.new(pence + other.pence)
  end

  def to_s
    number_to_currency(@pence/100.0, :unit => "£")
  end

  def method_missing(meth, *args)
    @pence.send(meth, *args)
  end
end

