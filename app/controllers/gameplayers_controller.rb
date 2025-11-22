class GameplayersController < ApplicationController
  def index
    matching_gameplayers = Gameplayer.all

    @list_of_gameplayers = matching_gameplayers.order({ :created_at => :desc })

    render({ :template => "gameplayer_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_gameplayers = Gameplayer.where({ :id => the_id })

    @the_gameplayer = matching_gameplayers.at(0)

    render({ :template => "gameplayer_templates/show" })
  end

  def create
    the_gameplayer = Gameplayer.new
    the_gameplayer.user_id = params.fetch("query_user_id")
    the_gameplayer.game_id = params.fetch("query_game_id")
    the_gameplayer.seat_number = params.fetch("query_seat_number")
    the_gameplayer.score = params.fetch("query_score")
    the_gameplayer.hand_cards = params.fetch("query_hand_cards")

    if the_gameplayer.valid?
      the_gameplayer.save
      redirect_to("/gameplayers", { :notice => "Gameplayer created successfully." })
    else
      redirect_to("/gameplayers", { :alert => the_gameplayer.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_gameplayer = Gameplayer.where({ :id => the_id }).at(0)

    the_gameplayer.user_id = params.fetch("query_user_id")
    the_gameplayer.game_id = params.fetch("query_game_id")
    the_gameplayer.seat_number = params.fetch("query_seat_number")
    the_gameplayer.score = params.fetch("query_score")
    the_gameplayer.hand_cards = params.fetch("query_hand_cards")

    if the_gameplayer.valid?
      the_gameplayer.save
      redirect_to("/gameplayers/#{the_gameplayer.id}", { :notice => "Gameplayer updated successfully." } )
    else
      redirect_to("/gameplayers/#{the_gameplayer.id}", { :alert => the_gameplayer.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_gameplayer = Gameplayer.where({ :id => the_id }).at(0)

    the_gameplayer.destroy

    redirect_to("/gameplayers", { :notice => "Gameplayer deleted successfully." } )
  end
end
