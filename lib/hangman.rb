require 'yaml'

class Game
  WORD_LIST = File.open('word_list.txt').readlines.filter { |word| word.length >= 5 && word.length <= 7 }
  attr_accessor :word, :chances, :already_guessed, :display_word

  def initialize(word = WORD_LIST.sample.chomp, chances = 10, already_guessed = [])
    @word = word
    @chances = chances
    @already_guessed = already_guessed
    @display_word = Array.new(word.length, '_')
    load_display_word if already_guessed != []
  end

  def load_display_word
    @already_guessed.each do |letter|
      puts letter
      update_display(letter)
    end
  end

  def valid_guess(guess, already_guessed)
    unless guess.match(/^[a-z]{1}$/)
      puts 'Must be 1 letter'
      return false
    end

    if already_guessed.include? guess
      puts "Already guessed #{guess}, choose another letter"
      return false
    end
    true
  end

  def update_display(guess)
    @word.split('').each_with_index do |letter, index|
      @display_word[index] = word[index] if letter == guess
    end
  end

  def play
    while @chances > 0
      puts ''
      puts word
      puts display_word.join('')
      puts "type 'save' to save and end game"
      puts 'Guess a letter: '
      guess = gets.chomp.downcase
      if guess == 'save'
        save_game
        puts 'Saved, exiting game...'
        return
      end

      # If invalid code, print why and start over, otherwise continue
      next unless valid_guess(guess, already_guessed)

      # Adding to already guessed list
      already_guessed.push(guess)

      if word.include? guess
        puts 'Correct!'
        update_display(guess)
        return if game_won? # End while loop if won
      else
        @chances -= 1
        puts "Wrong! #{@chances} left"
      end
    end
    game_over
  end

  def game_over
    puts "Word was #{word}"
    puts 'You lose!'
  end

  def game_won?
    return false if @display_word.include? '_'

    puts 'You Win!'
    true
  end

  def save_game
    dump = YAML.dump({
                       'word' => @word,
                       'chances' => @chances,
                       'already_guessed' => @already_guessed
                     })
    File.open('hangman_save.yaml', 'w') { |file| file.puts dump }
  end

  def self.load_game(savefile)
    data = YAML.load savefile
    new(data['word'], data['chances'].to_i, data['already_guessed'])
  end
end

response = ''
unless %w[y n].include?(response)
  puts 'Must be N or L'
  puts 'New game? Or Load save? N or L:'
  response = gets.chomp
end
game = if response == 'n'
         Game.new
       else
         Game.load_game(File.read('hangman_save.yaml'))
       end
game.play
