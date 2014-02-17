
require './game.rb'
require './player.rb'
require './cards.rb'

puts "Welcome to Kyle's Texas Hold'Em"
game = Game.new
3.times {|x| puts}
puts "Let's get started." 
game.play_hand
