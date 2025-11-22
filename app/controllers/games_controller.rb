class GamesController < ApplicationController
  def index
    matching_games = Game.all

    @list_of_games = matching_games.order({ :created_at => :desc })

    render({ :template => "game_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_games = Game.where({ :id => the_id })

    @the_game = matching_games.at(0)

    render({ :template => "game_templates/show" })
  end

  def create
    the_game = Game.new
    the_game.status = params.fetch("query_status")
    the_game.creator_id = params.fetch("query_creator_id")
    the_game.table_cards = params.fetch("query_table_cards")
    the_game.deck_state = params.fetch("query_deck_state")
    the_game.winning_user_id = params.fetch("query_winning_user_id")
    the_game.started_at = params.fetch("query_started_at")
    the_game.ended_at = params.fetch("query_ended_at")
    the_game.gameplayers_count = params.fetch("query_gameplayers_count")

    if the_game.valid?
      the_game.save
      redirect_to("/games", { :notice => "Game created successfully." })
    else
      redirect_to("/games", { :alert => the_game.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    the_game.status = params.fetch("query_status")
    the_game.creator_id = params.fetch("query_creator_id")
    the_game.table_cards = params.fetch("query_table_cards")
    the_game.deck_state = params.fetch("query_deck_state")
    the_game.winning_user_id = params.fetch("query_winning_user_id")
    the_game.started_at = params.fetch("query_started_at")
    the_game.ended_at = params.fetch("query_ended_at")
    the_game.gameplayers_count = params.fetch("query_gameplayers_count")

    if the_game.valid?
      the_game.save
      redirect_to("/games/#{the_game.id}", { :notice => "Game updated successfully." } )
    else
      redirect_to("/games/#{the_game.id}", { :alert => the_game.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    the_game.destroy

    redirect_to("/games", { :notice => "Game deleted successfully." } )
  end
end
