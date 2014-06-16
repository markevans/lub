class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :transaction_item, class_name: "Transaction", foreign_key: :transaction_id
  validates_presence_of :tag, :transaction_item
  validates_uniqueness_of :tag, scope: :transaction_id
end
