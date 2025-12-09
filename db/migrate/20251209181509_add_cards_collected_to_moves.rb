class AddCardsCollectedToMoves < ActiveRecord::Migration[8.0]
  def change
    add_column :moves, :cards_collected, :integer
  end
end
