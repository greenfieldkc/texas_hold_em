

class Player
  attr_reader :name
  attr_accessor :money, :cards_in_hand, :active, :money_to_call, :final_hand
  
  def initialize(name, money)
    @name = name
    @money = money
    @money_to_call = 0
    @active = true
    @cards_in_hand = []
    @final_hand = nil
  end

  def are_you_in?
    puts "#{self.name}, are you in?"
    response = gets.chomp.downcase
    if response == "yes" || response == "y"
      return true
    elsif response == "no" || response == "n"
      return false
    else
      puts "Invalid Entry: Please type 'yes' or 'y' for true, 'no', or 'n' for false"
      self.are_you_in?
    end
  end

end