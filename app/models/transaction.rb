require 'digest/md5'

class Transaction < ActiveRecord::Base

  validates_presence_of :date, :description, :amount
  validates_uniqueness_of :signature

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  before_validation {|tr| tr.signature = tr.generate_signature }

  scope :by_latest, ->{ order('date DESC') }
  scope :search, ->(term){ where("description LIKE '%#{term.upcase}%'") }
  scope :for_month, ->(month, year){
    beginning_of_month = "#{year}-#{month}-01".to_date
    where(:date => beginning_of_month..beginning_of_month.end_of_month)
  }
  scope :pos, ->{ where('amount > 0') }
  scope :neg, ->{ where('amount < 0') }

  def self.total
    Money.new sum(:amount)
  end

  def amount
    Money.new super
  end

  def balance
    Money.new super
  end

  def generate_signature
    Digest::MD5.hexdigest("#{date}#{amount}#{balance}")
  end

  def tags_list
    tags.map(&:name).join(', ')
  end
end
