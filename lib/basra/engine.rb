module Basra
  class Engine
    SUITS = %w[H D C S].freeze
    RANKS = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze

    def self.initial_deck
      SUITS.product(RANKS).map { |suit, rank| "#{rank}#{suit}" }.shuffle
    end

    def self.deal_initial(game)
      deck = initial_deck

      players = game.gameplayers.to_a

      players.each do |gp|
        hand = []
        4.times do
          hand << deck.pop
        end
        gp.hand_cards_array = hand
        gp.save!
      end

      table = []
      while table.length < 4 && !deck.empty?
        card = deck.pop
        rank = card_rank(card)
        if rank == 'J' || card == '7D'

          deck.unshift(card)
          deck.shuffle!
          next
        else
          table << card
        end
      end

      game.table_cards_array = table
      game.deck_state_array = deck
      game.status = 'started'
      game.started_at ||= Time.current
      game.save!
    end

    def self.deal_next_hand(game)
      deck = game.deck_state_array
      players = game.gameplayers.to_a

      players.each do |gp|
        next if gp.hand_cards_array.any?
        hand = []
        4.times do
          break if deck.empty?
          hand << deck.pop
        end
        gp.hand_cards_array = hand
        gp.save!
      end

      game.deck_state_array = deck
      game.save!
    end

    def self.apply_rules(table_cards, card_code)
      rank = card_rank(card_code)

      if rank == 'J'
        return { captured_cards: table_cards.dup, basra: false }
      end

      if card_code == '7D' || card_code == "7♦"
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

    def self.card_rank(code)
      code[0..-2]
    end

    def self.card_suit(code)
      code[-1]
    end

    def self.card_value(rank)
      return 1 if rank == 'A'
      return nil if %w[Q K J].include?(rank)
      rank.to_i.zero? ? nil : rank.to_i
    end

    def self.table_numeric_value(table_cards)
      table_cards.map { |c| card_value(card_rank(c)) || 0 }.sum
    end

    def self.find_sum_combo(table_cards, target)
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
end
