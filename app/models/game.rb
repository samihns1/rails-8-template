class Game < ApplicationRecord
  has_many :gameplayers, class_name: "Gameplayer", foreign_key: "game_id", dependent: :destroy
  has_many :invitations, class_name: "Invitation", foreign_key: "game_id", dependent: :destroy
  has_many :moves, class_name: "Move", foreign_key: "game_id", dependent: :destroy
  belongs_to :creator, class_name: "User", foreign_key: "creator_id", optional: true

  before_create :generate_room_code

  private

  def generate_room_code
    self.room_code ||= loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless Game.exists?(room_code: code)
    end
  end

  before_create :generate_room_code

  private

  def generate_room_code
    self.room_code ||= loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless Game.exists?(room_code: code)
    end
  end
end
