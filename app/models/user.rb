class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many  :moves, class_name: "Move", foreign_key: "user_id", dependent: :destroy
  has_many  :gameplayers, class_name: "Gameplayer", foreign_key: "user_id", dependent: :destroy
  has_many  :invitations, class_name: "Invitation", foreign_key: "sender_id", dependent: :destroy
  has_many  :games, class_name: "Game", foreign_key: "creator_id", dependent: :destroy
  has_many  :games, class_name: "Game", foreign_key: "winning_user_id", dependent: :destroy
end
