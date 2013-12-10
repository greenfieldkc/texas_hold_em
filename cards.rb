
class Card
  attr_accessor :suit, :value, :color #:dealt, #:owner #visible
  #visible is if card is public/private. eg players private until end, dealer always public, remaining deck private, etc
  
  def initialize(suit, value)
    @suit = suit
    @value = value
    if suit == 'hearts' || suit == 'diamonds'
      @color =  "red" 
    else
      @color = "black"
    end
   ##@dealt = dealt #boolean
   ## if @dealt == true
   ##   puts "dealt cards must have an owner. who owns this card?"
   ##   @owner = gets.chomp  #double check this: match gets.chomp to Player.name????
   ## else
   ##   @owner = nil
   ## end
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
  ##shuffle should later be put into a new_hand method
  
  return @card_deck
  end
        
end
