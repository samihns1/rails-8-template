class CreateGameplayers < ActiveRecord::Migration[8.0]
  def change
    create_table :gameplayers do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :seat_number
      t.integer :score
      t.text :hand_cards

      t.timestamps
    end
  end
end
