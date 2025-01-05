class Company < ApplicationRecord
  has_many :addresses, dependent: :destroy

  validates :name, :registration_number, presence: true
  validates :name, length: { maximum: 256 }
  validates :registration_number, uniqueness: true
end
