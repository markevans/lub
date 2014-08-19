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
  scope :cost, ->(amount) do
    case amount
    when Range then where(amount: (-amount.last*100..-amount.first*100))
    else where(amount: -amount*100)
    end
  end

  unique_taggings = "(SELECT DISTINCT(transaction_id) from taggings) t ON transactions.id=t.transaction_id"
  scope :tagged, ->{ joins("INNER JOIN #{unique_taggings}") }
  scope :not_tagged, ->{ joins("LEFT JOIN #{unique_taggings}")
                         .where("transaction_id IS NULL") }

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

  def tag!(name)
    transaction do
      tag = Tag.find_or_create_by!(name: name)
      taggings.create(tag: tag)
    end
  end

  def tag_list
    tags.map(&:name).join(', ')
  end
end
