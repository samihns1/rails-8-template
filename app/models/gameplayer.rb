class Gameplayer < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
  belongs_to :game, required: true, class_name: "Game", foreign_key: "game_id", counter_cache: true
end
