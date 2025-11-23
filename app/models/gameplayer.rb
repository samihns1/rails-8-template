# == Schema Information
#
# Table name: gameplayers
#
#  id          :bigint           not null, primary key
#  hand_cards  :text
#  score       :integer
#  seat_number :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  game_id     :integer
#  user_id     :integer
#
class Gameplayer < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
  belongs_to :game, required: true, class_name: "Game", foreign_key: "game_id", counter_cache: true
end
