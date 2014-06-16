class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :transaction_item, class_name: "Transaction", foreign_key: :transaction_id
  validates_presence_of :tag, :transaction_item
end
