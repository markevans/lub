# encoding: utf-8
require 'digest/md5'

class Transaction < ActiveRecord::Base

  validates_presence_of :date, :description, :amount
  validates_uniqueness_of :signature

  before_validation {|tr| tr.signature = tr.generate_signature }

  scope :by_latest, order('date DESC')
  scope :search, lambda{|term| where("description LIKE '%#{term.upcase}%'") }
  scope :for_month, lambda {|month, year|
    beginning_of_month = "#{year}-#{month}-01".to_date
    where(:date => beginning_of_month..beginning_of_month.end_of_month)
  }
  scope :pos, where('amount > 0')
  scope :neg, where('amount < 0')

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

  def amount
    Money.new super
  end

  def balance
    Money.new super
  end

  def self.total
    Money.new sum(:amount)
  end

  def generate_signature
    Digest::MD5.hexdigest("#{date}#{amount}#{balance}")
  end

end
