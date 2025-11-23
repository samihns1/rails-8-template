class GamesController < ApplicationController
  def index
    render({ :template => "game_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")
    matching_games = Game.where({ :id => the_id })
    @the_game = matching_games.at(0)

    render({ :template => "game_templates/show" })
  end

  def create
    if current_user.nil?
      redirect_to("/", { :alert => "You must have an account to start a game." })
      return
    end

    @game = Game.new

    @game.creator_id = current_user.id
    @game.status = "waiting"
    @game.started_at = Time.current
    @game.table_cards = [].to_json
    @game.deck_state = initial_deck.to_json

    if @game.valid?
      @game.save
      redirect_to("/games/#{@game.id}", { :notice => "Game created successfully." })
    else
      redirect_to("/games", { :alert => @game.errors.full_messages.to_sentence })
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
      redirect_to("/games/#{the_game.id}", { :notice => "Game updated successfully." })
    else
      redirect_to("/games/#{the_game.id}", { :alert => the_game.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    the_game.destroy

    redirect_to("/games", { :notice => "Game deleted successfully." })
  end

  def join_form
    matching_games = Game.all
    @list_of_games = matching_games.order({ :created_at => :desc })
    render({ :template => "game_templates/join" })
  end

  def join_by_code
    if current_user.nil?
      redirect_to("/", { :alert => "You must be signed in to join a game." })
      return
    end

    room_code = params.fetch("query_room_code").to_s.strip.upcase

    the_game = Game.where({ :room_code => room_code }).at(0)

    if the_game.nil?
      redirect_to("/join", { :alert => "No game found with that code." })
      return
    end

    existing = Gameplayer.where({ :game_id => the_game.id, :user_id => current_user.id }).at(0) # not working right now
    if existing.present?
      redirect_to("/games/#{the_game.id}", { :notice => "You are already in that game." })
      return
    end

    next_seat = the_game.gameplayers.count + 1

    new_gp = Gameplayer.new
    new_gp.game_id = the_game.id
    new_gp.user_id = current_user.id
    new_gp.seat_number = next_seat
    new_gp.score = 0
    new_gp.hand_cards = [].to_json

    if new_gp.valid?
      new_gp.save
      redirect_to("/games/#{the_game.id}", { :notice => "Joined game!" })
    else
      redirect_to("/join", { :alert => new_gp.errors.full_messages.to_sentence })
    end
  end

  private

  def initial_deck
    suits = %w[H D C S]
    ranks = %w[A 2 3 4 5 6 7 8 9 10 J Q K]

    suits.product(ranks).map { |suit, rank| "#{rank}#{suit}" }.shuffle
  end
end
