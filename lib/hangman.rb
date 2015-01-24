require 'yaml'

class Game
  attr_accessor :player

  def initialize
  	@secret_word = generate_word
  	@display_word = current_display
  	@player = Player.new(@secret_word)	
  	@misses = ''
  end
  
  def generate_word
    word_list = []

    # Loads dictionary and samples word with length between 5 & 12
    File.open('dictionary.txt','r').readlines.each do |word|
   	  if word.chomp.length.between?(5,12)
	    word_list << word.chomp
	  end
    end
    word_list.sample.downcase.chomp
  end

  def current_display
  	"_" * @secret_word.length.to_i
  end

  def misses_list(miss)
  	@misses << miss + ","
  end

  def update_display(ans)
    word = (0 ... @secret_word.length).find_all do |char|
      @secret_word[char,1] == ans 
    end
  	word.each {|count| @display_word[count] = ans }
  	puts @display_word
  end  

  def no_more_blanks? 
    if @display_word == @secret_word
      puts "You win!"
      true
  	else
      @player.try_again
  	  false
  	end
  end

  def next_turn
  	puts @display_word
    puts "Misses: #{@misses}"
  	puts "Select from one of the following options:"
  	puts "1. Enter a letter"
  	puts "2. Enter 'guess' to guess the word"
  	puts "3. Enter 'save' to save game"
  	ans = gets.chomp.downcase
  	if ans == 'guess'
  	  guess_word
  	elsif ans == 'save'
  	  save_game
  	else
  	  guess_letter(ans)
  	end
  end

  def guess_word
  	puts "Enter the word:"
  	ans_word = gets.chomp.downcase
  	if ans_word == @secret_word
  	  puts "You win! Correct the answer was #{ans_word}."
  	  true
    else
      puts "Sorry, incorrect guess. Try again!"
      @player.try_again
      false
    end	
  end

  def guess_letter(ans)
  	if @secret_word.include?(ans)
  		update_display(ans)
  		no_more_blanks?
  	else
  	  misses_list(ans)
      @player.try_again
  	  false
  	end
  end

  def save_game
  	YAML::dump(self)
    Dir.mkdir("saved") unless Dir.exists? "saved"

    filename = "saved/saved_game.yaml"

    File.open(filename, 'w+') { |f| f.puts YAML.dump(self)}
  end

  class Player

    def initialize(secret_word)
      @tries = 12
      @secret_word = secret_word
    end

    def tries_left 
      puts " "
      if @tries == 0
        puts "The answer is: #{@secret_word}"
        puts "You lose. Better luck next time!"
      else
        puts "Count: #{@tries} guesses left."
      end
      @tries
    end

    def try_again
      @tries -= 1
    end
  end

end


end_game = false

puts "Open saved game? (y/n)"
ans = gets.chomp.to_s
if ans == "y"
  # Loads YAML with saved game
  game_file = File.open("saved/saved_game.yaml")
  yaml = game_file.read
  hangman = YAML.load(yaml)
  YAML.dump(" ")
else
  hangman = Game.new
end

while hangman.player.tries_left > 0 && end_game == false
  end_game = hangman.next_turn
end