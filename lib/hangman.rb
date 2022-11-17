class Game
  WORD_LIST = File.open('word_list.txt').readlines.filter { |word| word.length >= 5 && word.length <= 7 }
  attr_accessor :word, :chances, :already_guessed, :display_word

  def initialize(word = WORD_LIST.sample.chomp, chances = 10, already_guessed = [])
    @word = word
    @chances = chances
    @already_guessed = already_guessed
    if already_guessed.empty?
      @display_word = Array.new(word.length, '_')
    else
      load_display_word
    end
    puts display_word.class
  end

  def load_display_word
    already_guessed.each do |letter|
      @display_word = update_display(letter, display_word)
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

  def update_display(guess, display_word)
    word.split('').each_with_index do |letter, index|
      display_word[index] = word[index] if letter == guess
    end
    display_word
  end

  def play
    while chances > 0
      puts ''
      p word
      puts 'Guess a letter: '
      guess = gets.chomp
      guess.downcase!
      next unless valid_guess(guess, already_guessed)

      already_guessed.push(guess) # Adding to already guessed list

      if word.include? guess
        puts 'Correct!'
        display_word = update_display(guess, display_word)
        break unless display_word.include? '_' # break if display_word doesn't have any guesses left
      else
        chances -= 1
        puts "Wrong! #{chances} left"
      end
    end
    # While loop ended either user won, or ran out of guesses
    puts "#{word}"
    if chances > 0
      puts 'You won!'
    else
      puts 'You lose!'
    end
  end
end

game = Game.new
game.play
