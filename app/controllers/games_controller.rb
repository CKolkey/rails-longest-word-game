require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = generate_letters(10)
  end

#The word can't be built out of the original grid
#The word is valid according to the grid, but is not a valid English word
#The word is valid according to the grid and is an English word

  def score
    word = params[:word_guess]
    letters = params[:letters]

    if valid_word?(word)
      if letters_available?(letters, word)
        @result = {letters: letters, word: word, win: true, reason: nil}
      else
        @result = {letters: letters, word: word, win: false, reason: 0}
      end
    else
      @result = {letters: letters, word: word, win: false, reason: 1}
    end
  end

  private

  def generate_letters(count)
    # Generates an array of random letters
    letters = []
    count.times do
      letters << ('A'..'Z').to_a[rand(0..25)]
    end
    return letters
  end

  def valid_word?(word)
    # Checks API to see if a word is valid
    # Returns true or false
    # https://wagon-dictionary.herokuapp.com/#{word}
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    remote_dictionary = open(url).read
    word_hash = ActiveSupport::JSON.decode(remote_dictionary)

    word_hash["found"]
  end

  def letters_available?(letters, word)
    dict_grid = {}
    grid = letters.split
    grid.uniq.each { |letter| dict_grid[letter] = grid.count(letter) }
    word.chars.each do |letter|
      return false unless dict_grid[letter.upcase]

      if dict_grid[letter.upcase].positive?
        dict_grid[letter.upcase] -= 1
      else
        return false
      end
    end
  end
end
