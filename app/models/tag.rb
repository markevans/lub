class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  has_many :transactions, through: :taggings
  validates_presence_of :name
end
