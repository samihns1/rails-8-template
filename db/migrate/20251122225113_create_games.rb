class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :status
      t.integer :creator_id
      t.text :table_cards
      t.text :deck_state
      t.integer :winning_user_id
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :gameplayers_count

      t.timestamps
    end
  end
end
