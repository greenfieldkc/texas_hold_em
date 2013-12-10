require './player.rb'
require './dealer.rb'
require './cards.rb'
   
class Game
  attr_accessor :players, :starting_money, :ante, :jackpot, :dealer, :undealt_deck, :dealt_deck, :cards_in_hand
  
  def initialize(starting_money=100, starting_ante=1)
      @players = []
      puts "How many players?"
      gets.chomp.to_i.times do |x| 
        puts "Player #{x}. Please Enter your Name:"
        name = gets.chomp
        @players << Player.new(name, starting_money)
      end
      @players.each {|player| puts "#{player.name} is seated at the table with $#{player.money}" }
      @ante = starting_ante
      @jackpot = 0
      @dealer = Dealer.new
      @cards_in_hand = []
      @undealt_deck = DeckOfCards.new.card_deck.shuffle
      @dealt_deck = []
  end
  
  def play_hand
    reset_for_new_hand
    ante_up
    deal_round
    puts
    puts "________________"
    flop
    puts
    puts "________________"
    turn
    puts
    puts "________________"
    river
    find_winner
  end
  
  def reset_for_new_hand
    @cards_in_hand = []
    @jackpot = 0
    @undealt_deck += @dealt_deck
    @undealt_deck.shuffle
    @players.each do |player| 
      player.cards_in_hand = []
      player.final_hand = nil
      player.money_to_call = 0
      player.active = true unless player.money == 0
    end
  end  
  
  def ante_up
    puts "The ante is $#{@ante}."
    @players.each do |player|
      player.money_to_call = @ante
      if player.are_you_in?     #see notes in player are_you_in? function to abstract further 
        player.money -= player.money_to_call
        @jackpot += player.money_to_call
        player.money_to_call = 0
      else
        player.active = false
        player.money_to_call = 0
      end
    end
    players.each {|player| puts "#{player.name} is in! He has $#{player.money} in chips left." if player.active == true}
    puts "The current pot value is: $#{@jackpot}."
    
  end  
  
  def deal_round
    @players.each {|player| 2.times {|x| deal_card(player)} if player.active == true}
    @players.each {|player| puts "#{player.name} was dealt the #{player.cards_in_hand[0]} and the #{player.cards_in_hand[1]}" }
    betting_sequence
  end
  
  def deal_card(recipient)
    recipient.cards_in_hand << "#{@undealt_deck[0][1]} of #{@undealt_deck[0][0]}" 
    @dealt_deck << @undealt_deck[0]
    @undealt_deck.shift
  end
  
  def place_bets
    @players.each do |player|
    if player.money_to_call == 0 && (player.active == true)
      puts "#{player.name}, would you like to check or bet?"
      response = gets.chomp.downcase
      if response == "bet"
        puts "How much would you like to bet?"
        bet = gets.chomp.to_i
        player.money -= bet
        @jackpot += bet
        @players.each {|person| (person.money_to_call += bet) unless (person.object_id == player.object_id)} ##can be abstracted
        puts "#{player.name} bet $#{bet}. The pot is now #{@jackpot}."
      elsif response == "check"
        puts "#{player.name} checked."
      else
        puts "Invalid Entry: Type 'bet' or 'check'"
        #need code to loop back up to if clause...
      end
    elsif player.active == true
      puts "#{player.name}, you need #{player.money_to_call} to call."
      puts "Would you like to fold, call, or raise?"
      response = gets.chomp.downcase
      if response == "fold"
        player.active = false
        player.money_to_call = 0
        puts "#{player.name} folded."
      elsif response == "call"
        player.money -= player.money_to_call
        @jackpot += player.money_to_call
        player.money_to_call = 0
        puts "#{player.name} called. The pot is now #{@jackpot}."
      elsif response == "raise"
        player.money -= player.money_to_call   #these three lines could be abstracted to Player class, but how to deal with jackpot?
        @jackpot += player.money_to_call
        player.money_to_call = 0
        puts "How much would you like to raise?"
        bet = gets.chomp.to_i
        player.money -= bet
        @jackpot += bet
        @players.each {|person| (person.money_to_call += bet) unless (person.object_id == player.object_id)}
        puts "#{player.name} bet $#{bet}. The pot is now #{@jackpot}."
      else   
        puts "Invalid Entry. Type 'fold', 'call', or 'raise' "
        #need code to loop back up to if clause...
      end      ###need to loop back around to continue call/raise process
    else
    end
    end
    players.each do |player|
      if (player.money_to_call > 0) && (player.active == true)
        puts "#{player.name}, $#{player.money_to_call} to call."
        puts "Would you like to call or fold?"
        response = gets.chomp.downcase
        if response == "fold"
          player.active = false
          player.money_to_call = 0
          puts "#{player.name} folded."
        elsif response == "call"
          player.money -= player.money_to_call
          @jackpot += player.money_to_call
          player.money_to_call = 0
          puts "#{player.name} called. The pot is now #{@jackpot}."
        else
          puts "Invalid Entry. Type 'fold' or 'call' "
          #need code to loop back up to if..."
        end
      else
      end
    end      
  end
  
  def flop
    puts "Time for the Flop!"
    3.times {|x| deal_card(self) }
    puts "Cards on Table: #{@cards_in_hand[0..-1]}"
    betting_sequence
  end
    
  def betting_sequence  
    place_bets
    check_active_players
    print_player_status
  end
  
  def turn
    puts "Time for the turn!"
    deal_card(self)
    puts "The turn is: #{@cards_in_hand[3]}"
    puts "Cards on Table: #{@cards_in_hand[0..-1]}"
    betting_sequence
  end  
  
  def river
    puts "Time for the River!"  
    deal_card(self)
    puts "The river is: #{@cards_in_hand[4]}"
    puts "Cards on Table: #{@cards_in_hand[0..-1]}"
    betting_sequence
  end
    
  def print_player_status
    @players.each do |player| 
      if player.active == true
        puts "#{player.name} is playing the hand and has $#{player.money} in chips. $#{player.money_to_call} to call. Cards: #{player.cards_in_hand}"
      else
        puts "#{player.name} is out, but still has $#{player.money} in chips."
      end
    end
  end
  
  def check_active_players
    active_players = []
    @players.each {|player| active_players << player if player.active == true}
    declare_winner if active_players.length == 1
  end
  
  def declare_winner #in the event everyone else folds...
    winner = []
    players.each { |player| winner << player if player.active == true }
    if winner.length > 1
      raise Exception , "It seems there are multiple winners. Hmmmmmm....."
    elsif winner.length < 1
      raise Exception , "It seems there are no winners. Hmmmmm......"
    else  
      winner[0].money += @jackpot
      @jackpot = 0
      puts "#{winner[0].name} won the hand and now has $#{winner[0].money}"
      play_another_hand
    end
  end
    
  def play_another_hand  
    puts "Would you like to play another hand?"
    response = gets.chomp.downcase
    if response == "yes" || response == "y"
      play_hand
    else
      puts "Game Over."
      @players.each {|player| puts "#{player.name} finished with $#{player.money}."}
      abort("Thanks for playing. Load 'ruby main.rb' to play again!")
    end 
  end      
    
  def find_winner #by evaluating final hands...
    winner = nil
    @players.each do |player|
    unless player.active == false
      possible_cards = player.cards_in_hand + @cards_in_hand
      possible_cards = parse_cards(possible_cards)
      player.final_hand = evaluate_hand(possible_cards)
      puts "#{player.name} is holding a #{player.final_hand[1]} "
      if winner == nil
        winner = player
      else
        winner = player if player.final_hand[0] > winner.final_hand[0]
      end
    end
    end
    puts "#{winner.name} won the hand and gets a pot of $#{@jackpot}!"
    winner.money += @jackpot
    @jackpot = 0
    puts "#{winner.name} now has $#{winner.money}"
    play_another_hand
  end

  def evaluate_hand(possible_cards)
      return [9, "straight flush"] if straight_flush?(possible_cards)
      return [8, "four of a kind"] if four_of_a_kind?(possible_cards)
      return [7, "full house"] if full_house?(possible_cards)
      return [6, "flush"] if flush?(possible_cards)
      return [5, "straight"] if straight?(possible_cards)
      return [4, "three of a kind"] if three_of_a_kind?(possible_cards)
      return [3,"two_pair"] if two_pair?(possible_cards)
      return [2, "one_pair"] if one_pair?(possible_cards)
      return [1, "high_card"]
  end    
  
  def one_pair?(cards) #takes an array of 2 numeric values representing [value,suit] eg: [12,4] represents queen of spades
    temp = []
    cards.each {|card| temp << card[0]}
    pair_count = 0
    (2..14).each {|num| pair_count += 1 if temp.count(num) == 2 }
    return true if pair_count == 1
    return false
  end
  
  def two_pair?(cards) #doesn't account for 2 players having two-pair
    temp = []
    cards.each {|card| temp << card[0]}
    pair_count = 0
    (2..14).each {|num| pair_count += 1 if temp.count(num) == 2 }
    return true if pair_count == 2
    return false
  end
  
  def three_of_a_kind?(cards)
    temp = []
    cards.each {|card| temp << card[0] }
    (2..14).each {|num| return true if temp.count(num) == 3}
    return false
  end


  def straight?(cards) #returns false in case of repeated value of a straight value, eg: 3 clubs,4 of clubs and 4 of spades, 5 hearts, etc...
    temp = []
    cards.each {|card| temp << card[0] }
    temp.sort!.uniq!
    return false if temp.length < 5
    #puts "inside straight function temp values #{temp}"
    if temp[1] - 1 == temp[0] 
      if temp[2] - 1 == temp[1]
        if temp[3] - 1 == temp[2]
          if temp[4] - 1 == temp[3]
            return true
          end
        end
      end
    end
    return false if temp.length < 6
    if temp[2] - 1 == temp[1] 
      if temp[3] - 1 == temp[2]
        if temp[4] - 1 == temp[3]
          if temp[5] - 1 == temp[4]
            return true
          end
        end
      end
    end
    return false if temp.length < 7
    if temp[3] - 1 == temp[2] 
      if temp[4] - 1 == temp[3]
        if temp[5] - 1 == temp[4]
          if temp[6] - 1 == temp[5]
            return true
          end
        end
      end
    end
    return false
  end

  
  def flush?(cards)
    temp = []
    cards.each {|card| temp << card[1] }
    return true if (temp.count(1) >= 5) || (temp.count(2) >= 5) || (temp.count(3) >= 5) || (temp.count(4) >= 5)
    return false
  end
  
  def full_house?(cards)
    return true if one_pair?(cards) && three_of_a_kind?(cards)
    return false
  end
  
  def four_of_a_kind?(cards)
    temp = []
    cards.each {|card| temp << card[0] }
    (2..14).each {|num| return true if temp.count(num) == 4}
    return false
  end
  
  def straight_flush?(cards)
    suit_value = []
    flush_cards = []
    cards.each {|card| suit_value << card[1] }
    if suit_value.count(1) >= 5
      cards.each {|card| flush_cards << card if (card[1] == 1) }
    elsif suit_value.count(2) >= 5
      cards.each {|card| flush_cards << card if (card[1] == 2) }
    elsif suit_value.count(3) >= 5
      cards.each {|card| flush_cards << card if (card[1] == 3) }
    elsif suit_value.count(4) >= 5
      cards.each {|card| flush_cards << card if (card[1] == 4) }
    end
    #puts "inside straight flush. flush cards: #{flush_cards}"
    if flush_cards.length >= 5
      if straight?(flush_cards)
        return true
      end
    end
    return false
  end
  
  
  def parse_cards(cards)
    card_array = []
    cards.each do |card|
      suit_num = 1 if !! card.match(/clubs/)
      suit_num = 2 if !! card.match(/diamonds/)
      suit_num = 3 if !! card.match(/hearts/)
      suit_num = 4 if !! card.match(/spades/)
      val_num = 2 if !! card.match(/2/)
      val_num = 3 if !! card.match(/3/)
      val_num = 4 if !! card.match(/4/)
      val_num = 5 if !! card.match(/5/)
      val_num = 6 if !! card.match(/6/)
      val_num = 7 if !! card.match(/7/)
      val_num = 8 if !! card.match(/8/)
      val_num = 9 if !! card.match(/9/)
      val_num = 10 if !! card.match(/10/)
      val_num = 11 if !! card.match(/jack/)
      val_num = 12 if !! card.match(/queen/)
      val_num = 13 if !! card.match(/king/)
      val_num = 14 if !! card.match(/ace/)
      card_array << [val_num, suit_num] 
    end
    return card_array
  end
  
    
end

=begin
Card Hand Tests:
game = Game.new
puts game.evaluate_hand([[11,4],[4,3],[5,3],[6,3],[11,1],[7,3],[3,3]]) #straight flush
puts game.evaluate_hand([[11,4],[12,4],[13,4],[6,4],[9,4],[11,2],[10,4]]) #straight_flush
puts game.evaluate_hand([[11,4],[11,3],[5,3],[6,4],[11,1],[11,2],[9,4]]) #four of a kind
puts game.evaluate_hand([[14,2],[14,4],[5,3],[14,1],[7,3],[13,3],[14,3]]) #four of a kind
puts game.evaluate_hand([[11,4],[14,4],[5,3],[6,4],[7,4],[8,2],[9,4]]) #flush
puts game.evaluate_hand([[11,3],[14,4],[5,3],[6,3],[7,3],[13,3],[9,3]]) #flush
puts game.evaluate_hand([[12,2],[4,4],[5,3],[6,2],[7,4],[8,2],[9,2]]) #straight
puts game.evaluate_hand([[3,2],[4,4],[5,3],[6,2],[7,4],[5,2],[2,2]]) #straight
puts game.evaluate_hand([[3,2],[4,4],[3,3],[4,2],[3,4],[5,2],[2,2]]) #full house
puts game.evaluate_hand([[3,2],[4,4],[3,3],[3,1],[10,4],[5,2],[2,2]]) #three of a kind
puts game.evaluate_hand([[3,2],[4,4],[3,3],[4,2],[10,4],[5,2],[2,2]]) #two pair
puts game.evaluate_hand([[3,2],[4,4],[12,3],[14,2],[14,4],[5,2],[2,2]]) #one pair
puts game.evaluate_hand([[3,2],[4,4],[12,3],[14,2],[8,4],[5,2],[2,2]]) #high card
                  
=end