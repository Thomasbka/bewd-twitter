class Session < ApplicationRecord
  belongs_to :user

  before_validation :generate_session_token

  validates :user_id, presence: true
  validates :token, presence: true, uniqueness: true

  private

  def generate_session_token
    self.token ||= SecureRandom.hex(10)
  end
end
