class CreateMoves < ActiveRecord::Migration[8.0]
  def change
    create_table :moves do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :move_number
      t.string :card_player
      t.text :captured_cards
      t.boolean :basra
      t.integer :points_earned

      t.timestamps
    end
  end
end
