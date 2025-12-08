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

  validates :email, uniqueness: true
  validates :username, uniqueness: true

  def wins_count
    Game.where(winning_user_id: id).count
  end

  def losses_count
    Game.joins(:gameplayers)
        .where(gameplayers: { user_id: id })
        .where(status: 'finished')
        .where.not(winning_user_id: id)
        .distinct
        .count
  end

  def self.leaderboard
    wins = Game.where.not(winning_user_id: nil).group(:winning_user_id).count
    participated = Game.joins(:gameplayers).where(status: 'finished').group('gameplayers.user_id').count

    all.map do |u|
      w = wins[u.id] || 0
      p = participated[u.id] || 0
      { user: u, wins: w, losses: (p - w) }
    end.sort_by { |h| -h[:wins] }
  end
end
