class MovesController < ApplicationController
  def index
    matching_moves = Move.all

    @list_of_moves = matching_moves.order({ :created_at => :desc })

    render({ :template => "move_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_moves = Move.where({ :id => the_id })

    @the_move = matching_moves.at(0)

    render({ :template => "move_templates/show" })
  end

  def create
    the_move = Move.new
    the_move.game_id = params.fetch("query_game_id")
    the_move.user_id = params.fetch("query_user_id")
    the_move.move_number = params.fetch("query_move_number")
    the_move.card_player = params.fetch("query_card_player")
    the_move.captured_cards = params.fetch("query_captured_cards")
    the_move.basra = params.fetch("query_basra")
    the_move.points_earned = params.fetch("query_points_earned")

    if the_move.valid?
      the_move.save
      redirect_to("/moves", { :notice => "Move created successfully." })
    else
      redirect_to("/moves", { :alert => the_move.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_move = Move.where({ :id => the_id }).at(0)

    the_move.game_id = params.fetch("query_game_id")
    the_move.user_id = params.fetch("query_user_id")
    the_move.move_number = params.fetch("query_move_number")
    the_move.card_player = params.fetch("query_card_player")
    the_move.captured_cards = params.fetch("query_captured_cards")
    the_move.basra = params.fetch("query_basra")
    the_move.points_earned = params.fetch("query_points_earned")

    if the_move.valid?
      the_move.save
      redirect_to("/moves/#{the_move.id}", { :notice => "Move updated successfully." } )
    else
      redirect_to("/moves/#{the_move.id}", { :alert => the_move.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_move = Move.where({ :id => the_id }).at(0)

    the_move.destroy

    redirect_to("/moves", { :notice => "Move deleted successfully." } )
  end
end
