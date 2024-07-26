class User < ApplicationRecord
  has_secure_password

  has_many :sessions
  has_many :tweets

  validates :username, presence: true, length: { in: 3..64 }, uniqueness: true
  validates :email, presence: true, length: { in: 5..500 }, uniqueness: true
  validates :password, length: { in: 8..64 }, if: :password
end
