# == Schema Information
#
# Table name: games
#
#  id                :bigint           not null, primary key
#  deck_state        :text
#  ended_at          :datetime
#  gameplayers_count :integer
#  max_players       :integer
#  name              :string
#  room_code         :string
#  started_at        :datetime
#  status            :string
#  table_cards       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  current_player_id :integer
#  winning_user_id   :integer
#
# Indexes
#
#  index_games_on_current_player_id  (current_player_id)
#
class Game < ApplicationRecord
  has_many :gameplayers, class_name: "Gameplayer", foreign_key: "game_id", dependent: :destroy
  has_many :invitations, class_name: "Invitation", foreign_key: "game_id", dependent: :destroy
  has_many :moves, class_name: "Move", foreign_key: "game_id", dependent: :destroy
  belongs_to :creator, class_name: "User", foreign_key: "creator_id", optional: true

  before_create :generate_room_code
  def table_cards_array
    JSON.parse(table_cards || "[]")
  end

  def table_cards_array=(arr)
    self.table_cards = arr.to_json
  end

  def deck_state_array
    JSON.parse(deck_state || "[]")
  end

  def deck_state_array=(arr)
    self.deck_state = arr.to_json
  end

  private

  def generate_room_code
    self.room_code ||= loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless Game.exists?(room_code: code)
    end
  end
end
