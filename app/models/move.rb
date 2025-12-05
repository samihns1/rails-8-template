# == Schema Information
#
# Table name: moves
#
#  id             :bigint           not null, primary key
#  basra          :boolean
#  captured_cards :text
#  card_player    :string
#  move_number    :integer
#  points_earned  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  game_id        :integer
#  user_id        :integer
#
class Move < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
  belongs_to :game, required: true, class_name: "Game", foreign_key: "game_id"

  alias_attribute :card_played, :card_player
end
