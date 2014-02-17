
class Card
  attr_accessor :suit, :value, :color
 
  def initialize(suit, value)
    @suit = suit
    @value = value
    if suit == 'hearts' || suit == 'diamonds'
      @color =  "red" 
    else
      @color = "black"
    end
  end  

end


class DeckOfCards < Array
attr_accessor :card_deck
  def initialize
  @card_deck = Array.new
  card_values = ["2","3","4","5","6","7","8","9","10","jack","queen","king","ace"]
  card_suits = ["clubs","spades", "hearts", "diamonds"]
  card_suits.each do |suit|
    card_values.each do |value| 
      card = Card.new(suit, value)
      @card_deck << [card.suit, card.value, card.color]
    end
  end
  puts "New deck has been created! Total cards: #{@card_deck.length}"
  return @card_deck
  end
        
end
