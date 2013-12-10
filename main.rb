
require './game.rb'
require './player.rb'
require './cards.rb'

puts "Welcome to Kyle's Texas Hold'Em"
game = Game.new
3.times {|x| puts}
puts "Let's get started." 
game.play_hand

=begin
Texas Hold'Em


- create a deck of cards
- create players: name, starting money
- ante up
- deal 2 cards to each player
- players bet: check, raise, call, or fold
- flop 3 cards publicly from deck
- players bet
- flip 1 card publicly
- players bet
- flip 1 card publicly
- players bet
- all hands shown, declare winner

=end