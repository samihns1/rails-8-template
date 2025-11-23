# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
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
