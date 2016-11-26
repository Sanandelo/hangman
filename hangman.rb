 require 'yaml'

	#Generate game word
	class WordGenerator
		def initialize
			@arr = Array.new 
		end
		def creat_list
			File.new("5desk.txt","r").each do |line| 
				line.chomp!
				if line.length >= 5 && line.length <= 12
					@arr << line
				end
			end
		end
		def generate
			numb = rand(0...@arr.size)
			@arr[numb]
		end

	end


	#Display respond to user
	class View

		def show_initial_conditions(number)
			puts "Hello user, you're playing Hangman. The word we guessing have #{number} of letters. You have 9 tires"
			puts " "
		end

		def show_respond(string, tries)
			puts "Your word #{string}, you have #{tries} tries"
			puts " "
		end 
	end



	#Take input from user
	class Player
		attr_accessor :answer, :previous

		def initialize
			@answer = nil
			@previous = Array.new()
		end

		def letter?(lookAhead)
 		 lookAhead =~ /[[:alpha:]]/
		end
		def valid?(val)
			respond = true

			unless @previous.empty?
				if @previous.include?(val)
					respond = false
				end
			end
			unless letter?(val)
				respond = false
			end
			respond
		end

		def get_letter
			cheker = true
			while cheker
				puts "Put your letter"
				@answer = gets.chomp
				unless valid?(@answer)
					puts "Wrong input. You probobly already chosen this letter, or you put invalid value"
					puts " "
				else
					cheker = false
				end
			end
			@previous << @answer
			@answer
		end
	end

	#Proccesing the game 
	class Engine
		attr_accessor :word, :player, :arr, :i, :check
		def initialize
			@generator = WordGenerator.new
			@player = Player.new
			@view = View.new
			@word = nil
			@answer = nil
			@arr = nil
			@i = 9
			@check = true
		end

		def letterMatch(word,answer)	
			isMatch = false
			word.downcase!
			answer.downcase!
			word_array = word.split("")
				word_array.each_with_index do |val,ind|
					if val ==  answer
						@arr[ind] = val
						isMatch =true
					end
				end
				isMatch
		end

		def win?(arr)
			if arr.include?("_")
				return false
			else
				return true
			end
		end

		def to_yaml
			YAML.dump({
				:player => @player,
				:word => @word,
				:arr => @arr,
				:i => @i,
				:check => @check
				})
		end
		


		def play
			@generator.creat_list
			@word = @generator.generate
			@arr = Array.new(@word.size, "_")
			@view.show_initial_conditions(@word.size)
			puts "Do you want to load game?(y/n)"
			load = gets.chomp
			if load == "y"
				file = YAML.load_file("save.yaml")
				@player = file[:player]
				@word = file[:word]
				@arr = file[:arr]
				@i = file[:i]
				@check = file[:check]
			end		

			while @check && @i>0
				puts "Do you want to save game?(y/n)"
				save = gets.chomp
				if save == "y"
					File.open("save.yaml", "w"){ |i| i.puts to_yaml}
					puts "Game saved"
				end
				@answer = @player.get_letter
				isMatch = letterMatch(@word, @answer)
				unless isMatch
					@i -=1
				end
				@view.show_respond(@arr.join, @i)
				if win?(@arr)
					puts "You win. My congratulations"
					@check = false
				end
			end
			if @check == true
				puts "Sorry but you're lose. The word was #{@word}"
			end
		end
	end


	engin = Engine.new
	engin.play

