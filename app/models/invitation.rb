class Invitation < ApplicationRecord
  belongs_to :game, required: true, class_name: "Game", foreign_key: "game_id"
end
