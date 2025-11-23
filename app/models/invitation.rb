# == Schema Information
#
# Table name: invitations
#
#  id              :bigint           not null, primary key
#  reciptent_email :string
#  status          :string
#  token           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_id         :integer
#  sender_id       :integer
#
class Invitation < ApplicationRecord
  belongs_to :game, required: true, class_name: "Game", foreign_key: "game_id"
end
