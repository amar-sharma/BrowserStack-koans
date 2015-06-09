# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.
$LOAD_PATH << File.dirname(__FILE__)
require 'about_dice_project'
module Color
    #shamelessly stolen (and modified) from redgreen
    COLORS = {
      :clear   => 0,  :black   => 30, :red   => 31,
      :green   => 32, :yellow  => 33, :blue  => 34,
      :magenta => 35, :cyan    => 36,
    }

    module_function

    COLORS.each do |color, value|
      module_eval "def #{color}(string); colorize(string, #{value}); end"
      module_function color
    end

    def colorize(string, color_value)
      if use_colors?
        color(color_value) + string + color(COLORS[:clear])
      else
        string
      end
    end

    def color(color_value)
      "\e[#{color_value}m"
    end

    def use_colors?
      return false if ENV['NO_COLOR']
      if ENV['ANSI_COLOR'].nil?
        if using_windows?
          using_win32console
        else
          return true
        end
      else
        ENV['ANSI_COLOR'] =~ /^(t|y)/i
      end
    end

    def using_windows?
      File::ALT_SEPARATOR
    end

    def using_win32console
      defined? Win32::Console
    end
  end
class Player
	attr_reader :name, :score
	attr_writer :score
	def initialize(name,score=0)
		@name = name
		@score = score
	end
end

class Game
	attr_reader :number_of_dices
	def initialize(number_of_dices)
		@number_of_players = 0
		@players = []
		@number_of_dices = number_of_dices
	end

	def display_scoreboard(players)
		puts "\n\n\tScoreboard\n "
		players.each do |player|
			puts Color.red("\n Player #{player.name}:\t#{player.score}")
		end
	end

	def start_game()
		puts Color.red("\n\t\t**** Welcome to GREED ****\n")
		print "\n Enter Number of Players: "
		number = gets.chomp
		@number_of_players = number.to_i
		@number_of_players.times do |i|
			print "Enter name of Player \##{i+1}: "
			name = gets.chomp
			@players.push << Player.new(name) 
		end
		play_game(@players)
	end

	def play_game(players)
		endgame = false
		rno = 0
		while !endgame do
			rno+=1
			puts Color.blue("\n\t Round #{rno} ")
			endgame = play_round(players)
			display_scoreboard(players)
		end
		if endgame
			puts Color.red("\n\t Final Round ")
			play_round(players)
		end
		maxscore = 0
		winner = ""
		players.each do |player|
			if player.score > maxscore
				winner = player.name
				maxscore = player.score
			end
		end
		puts Color.green("\n\t\t\t Congratulations #{winner} You Won!!!!!\n\n")
	end

	def play_round(players)
		dices = DiceSet.new
		round_players = players
		players.each do |player|
			if player.score < 3000
				print Color.magenta("\nRolling dice for Player #{player.name} ")
				@number_of_dices.times do
					sleep 0.2
					print Color.red('. ')
				end
				round_score,left_scoring = score(x = dices.roll(number_of_dices))
				puts "\nDices rolled: #{x}\nScored: #{round_score}\nScoring Dices left: #{left_scoring}"
				if player.score+round_score >= 300
					print "Continue(y/n)?: "
					choice = gets.chomp
					while choice.downcase == "y" && left_scoring > 0
						print Color.magenta("\nRolling dice for Player #{player.name}")
						round_score_t,left_scoring = score(x = dices.roll(left_scoring))
						if left_scoring == 0
							left_scoring=@number_of_dices
						end
						if round_score_t == 0
							left_scoring = 0
							round_score = 0
							puts "\nDices rolled: #{x}\nScored: #{round_score_t}\nScoring Dices left: #{left_scoring}"
							puts "\n\n\t ### No Scoring Dice #{player.name} lost this turn! ###"
							break
						end
						puts "\nDices rolled: #{x}\nScored: #{round_score_t}\nScoring Dices left: #{left_scoring}"
						round_score+=round_score_t
						print "Continue(y/n)?: "
						choice = gets.chomp
					end
					player.score +=round_score
					if(player.score >= 3000)
						return true
					end
				end
			end
		end
		false
	end
	def score(dice)
	  # You need to write this method
	  score = 0
	  left_scoring = dice.size
	  rep = Hash.new(0)
	  dice.each do |num|
	    rep[num]+=1
	    if num == 1
	      score+=100
	      left_scoring-=1
	    elsif num == 5
	      score+=50
	      left_scoring-=1
	    end
	    if rep[num]==3
	      rep[num]=0
	      if num == 1
	        score+=700
	      elsif num == 5
	        score+= 350
	      else
	        score+=num*100
	        left_scoring-=3
	      end
	    end
	    prev = num
	  end
	  return [score,left_scoring]
	end
end

game = Game.new(5)
game.start_game