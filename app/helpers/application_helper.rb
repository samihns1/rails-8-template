module ApplicationHelper
	def card_css_class(card_code)
		return 'card-back' if card_code.blank?
		suit = card_code[-1]
		['H', 'D'].include?(suit) ? 'red-card' : 'black-card'
	end

	def card_display_name(card_code)
		return '' if card_code.blank?
		rank = card_code[0..-2]
		suit = card_code[-1]
		suit_symbol = case suit
									when 'H' then '♥'
									when 'D' then '♦'
									when 'C' then '♣'
									when 'S' then '♠'
									end
		"#{rank}#{suit_symbol}"
	end
end
