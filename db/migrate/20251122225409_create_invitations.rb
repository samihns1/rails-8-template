class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations do |t|
      t.integer :sender_id
      t.string :reciptent_email
      t.integer :game_id
      t.string :token
      t.string :status

      t.timestamps
    end
  end
end
