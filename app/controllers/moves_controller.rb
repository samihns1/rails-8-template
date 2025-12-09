class MovesController < ApplicationController
  def index
    matching_moves = Move.all
    @list_of_moves = matching_moves.order({ created_at: :desc })
    render({ template: "move_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")
    matching_moves = Move.where({ id: the_id })
    @the_move = matching_moves.at(0)
    render({ template: "move_templates/show" })
  end

  def create
    if current_user.nil?
      redirect_to("/", { alert: "You must be signed in to play a card." })
      return
    end

    game_id = params.fetch("query_game_id").to_i
    card_code = params.fetch("query_card_played")

    @game = Game.where(id: game_id).first

    if @game.nil?
      redirect_to("/", { alert: "Game not found." })
      return
    end

    gameplayer = Gameplayer.where(game_id: @game.id, user_id: current_user.id).first

    if gameplayer.nil?
      redirect_to("/games/#{@game.id}", { alert: "You are not a player in this game." })
      return
    end

    if @game.current_player_id.present? && current_user.id != @game.current_player_id
      current_player = User.where(id: @game.current_player_id).first
      name = current_player ? current_player.username : 'another player'
      redirect_to("/games/#{@game.id}", { alert: "It's not your turn. Waiting for #{name}." })
      return
    end

    hand = gameplayer.hand_cards_array

    unless hand.include?(card_code)
      redirect_to("/games/#{@game.id}", { alert: "You don't have that card in your hand." })
      return
    end

    hand.delete(card_code)
    gameplayer.hand_cards_array = hand

    table = @game.table_cards_array

    capture_result = Basra::Engine.apply_rules(table, card_code)
    captured_cards = capture_result[:captured_cards]
    basra = capture_result[:basra]

    if captured_cards.any?
      new_table = table - captured_cards
    else
      new_table = table + [card_code]
    end
    @game.table_cards_array = new_table

    move = Move.new
    move.game_id = @game.id
    move.user_id = current_user.id
    move.move_number = (@game.moves.count + 1)
    move.card_played = card_code
    move.captured_cards = captured_cards.to_json
    move.basra = basra
    move.points_earned = basra ? 10 : 0

    card_count = captured_cards.length
    card_count += 1 if card_count > 0 && card_code.present?
    move.cards_collected = card_count
    
    move.round_points = 0

    if move.valid? && gameplayer.valid? && @game.valid?
      players = @game.gameplayers.order(:seat_number).to_a
      current_index = players.find_index { |gp| gp.user_id == current_user.id }
      next_user_id = nil
      if current_index
        next_gp = players[(current_index + 1) % players.length]
        next_user_id = next_gp.user_id
      end

      Move.transaction do
        move.save!
        gameplayer.save!
        @game.current_player_id = next_user_id if next_user_id
        @game.save!
      end

      all_hands_empty = @game.gameplayers.all? { |gp| gp.hand_cards_array.empty? }

      if all_hands_empty
        if @game.deck_state_array.any?
          Basra::Engine.deal_next_hand(@game)
        else
          if @game.table_cards_array.any?
            last_capture = @game.moves.where.not(captured_cards: [nil, "[]"]).order(created_at: :desc).first
            if last_capture.present?
              last_take = Move.new
              last_take.game_id = @game.id
              last_take.user_id = last_capture.user_id
              last_take.move_number = (@game.moves.count + 1)
              last_take.card_played = nil
              last_take.captured_cards = @game.table_cards_array.to_json
              last_take.basra = false
              last_take.points_earned = 0
              Move.transaction do
                last_take.save!
                @game.table_cards_array = []
                
                prev_last_take = @game.moves.where(card_played: nil).order(created_at: :desc).second
                
                current_round_moves = if prev_last_take
                  @game.moves.where("created_at > ? AND created_at <= ?", prev_last_take.created_at, last_take.created_at).where.not(captured_cards: [nil, "[]"])
                else
                  @game.moves.where("created_at <= ?", last_take.created_at).where.not(captured_cards: [nil, "[]"])
                end
                
                round_points_per_player = Hash.new(0)
                card_counts_per_player = Hash.new(0)
                
                @game.gameplayers.each do |gp|
                  round_points_per_player[gp.user_id] = 0
                  card_counts_per_player[gp.user_id] = 0
                end
                
                current_round_moves.each do |m|
                  begin
                    round_points_per_player[m.user_id] += (m.points_earned || 0)
                    
                    arr = JSON.parse(m.captured_cards.to_s)
                    card_count = arr.length
                    card_count += 1 if card_count > 0 && m.card_played.present?
                    card_counts_per_player[m.user_id] += card_count
                  rescue JSON::ParserError
                    next
                  end
                end

                active_players = @game.gameplayers.count
                majority_threshold = (52.0 / active_players).ceil + 1

                round_totals = {}
                card_counts_per_player.each do |user_id, card_count|
                  gp = Gameplayer.find_by(game_id: @game.id, user_id: user_id)
                  if gp
                    majority_bonus = card_count >= majority_threshold ? 30 : 0
                    total_round_points = round_points_per_player[user_id] + majority_bonus
                    round_totals[user_id] = total_round_points
                    
                    gp.score = (gp.score || 0) + total_round_points
                    gp.save!
                  end
                end

                @game.last_round_stats = round_totals.to_json
                
                max_score = @game.gameplayers.maximum(:score) || 0
                if max_score >= 180
                  tied_user_ids = @game.gameplayers.where(score: max_score).pluck(:user_id)
                  
                  if tied_user_ids.length == 1
                    @game.winning_user_id = tied_user_ids.first
                    @game.status = 'finished'
                    @game.ended_at = Time.current
                  else
                    @game.status = 'waiting'
                  end
                else
                  @game.status = 'waiting'
                end
                
                @game.save!
              end
            end
          end
        end
      end

      if @game.status == 'finished' && @game.winning_user_id.present?
        begin
          GameChannel.broadcast_to(@game, { event: 'winner', winning_user_id: @game.winning_user_id })
        rescue => e
          Rails.logger.info "GameChannel broadcast failed: #{e.message}"
        end

        winner_username = User.find_by(id: @game.winning_user_id)&.username
        redirect_to("/games/#{@game.id}/winner", { notice: "#{winner_username} has won the game!" })
        return
      end

      redirect_to("/games/#{@game.id}")
    else
      errors = (move.errors.full_messages +
                gameplayer.errors.full_messages +
                @game.errors.full_messages).uniq
      redirect_to("/games/#{@game.id}", { alert: errors.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_move = Move.where({ id: the_id }).at(0)

    the_move.game_id = params.fetch("query_game_id")
    the_move.user_id = params.fetch("query_user_id")
    the_move.move_number = params.fetch("query_move_number")
    the_move.card_played = params.fetch("query_card_played")
    the_move.captured_cards = params.fetch("query_captured_cards")
    the_move.basra = params.fetch("query_basra")
    the_move.points_earned = params.fetch("query_points_earned")

    if the_move.valid?
      the_move.save
      redirect_to("/moves/#{the_move.id}", { notice: "Move updated successfully." })
    else
      redirect_to("/moves/#{the_move.id}", { alert: the_move.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_move = Move.where({ id: the_id }).at(0)
    the_move.destroy
    redirect_to("/moves", { notice: "Move deleted successfully." })
  end

  private

  def apply_basra_rules(table_cards, card_code)
    rank = card_rank(card_code)
    suit = card_suit(card_code)

    if rank == "J"
      return { captured_cards: table_cards.dup, basra: false }
    end

    if card_code == "7♦" || card_code == "7D"
      total_table_value = table_numeric_value(table_cards)
      if total_table_value == 7 || table_cards.length == 1
        return { captured_cards: table_cards.dup, basra: true }
      else
        return { captured_cards: table_cards.dup, basra: false }
      end
    end

    captured = []

    same_rank_cards = table_cards.select { |c| card_rank(c) == rank }
    captured.concat(same_rank_cards)

    value = card_value(rank)
    if value
      sum_combo = find_sum_combo(table_cards, value)
      captured.concat(sum_combo) if sum_combo
    end

    captured.uniq!

    basra = false
    if captured.any?
      remaining = table_cards - captured
      basra = remaining.empty?
    end

    { captured_cards: captured, basra: basra }
  end

  def card_rank(code)
    code[0..-2]
  end

  def card_suit(code)
    code[-1]
  end

  def card_value(rank)
    return 1 if rank == "A"
    return nil if ["Q", "K", "J"].include?(rank)
    rank.to_i.zero? ? nil : rank.to_i
  end

  def table_numeric_value(table_cards)
    table_cards.map { |c| card_value(card_rank(c)) || 0 }.sum
  end

  def find_sum_combo(table_cards, target)
    numeric_cards = table_cards.select { |c| card_value(card_rank(c)) }
    n = numeric_cards.length
    (1..n).each do |k|
      numeric_cards.combination(k).each do |combo|
        sum = combo.map { |c| card_value(card_rank(c)) }.sum
        return combo if sum == target
      end
    end
    nil
  end
end
