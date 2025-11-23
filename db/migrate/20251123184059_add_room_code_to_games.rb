class AddRoomCodeToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :room_code, :string
  end
end
