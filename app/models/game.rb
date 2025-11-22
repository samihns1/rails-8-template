class Game < ApplicationRecord
  has_many  :gameplayers, class_name: "Gameplayer", foreign_key: "game_id", dependent: :destroy
  has_many  :invitations, class_name: "Invitation", foreign_key: "game_id", dependent: :destroy
  has_many  :moves, class_name: "Move", foreign_key: "game_id", dependent: :destroy
end
