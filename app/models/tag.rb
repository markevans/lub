class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  has_many :transactions, through: :taggings
  validates :name, presence: true, uniqueness: true
end
