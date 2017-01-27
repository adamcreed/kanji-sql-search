class Input
  def self.choice(range)
    choice = gets.chomp

    until Validator.is_within_bounds?(choice, range)
      print "Please enter #{range.min}-#{range.max}: "
      choice = gets.chomp
    end

    choice.to_i
  end

  def self.search_term
    term = gets.chomp

    until Validator.is_search_term?(term)
      print 'Please enter a meaning, kanji, reading, or stroke count: '
      term = gets.chomp
    end

    term
  end

  def self.kanji
    kanji = gets.chomp

    until Validator.is_kanji?(kanji)
      print 'Please enter a kanji: '
      kanji = gets.chomp
    end

    kanji
  end

  def self.number
    number = gets.chomp

    until Validator.is_number?(number)
      print 'Please enter a number: '
      number = gets.chomp
    end

    number
  end

  def self.word
    word = gets.chomp

    until Validator.is_word?(word)
      print 'Please enter a word: '
      word = gets.chomp
    end

    word
  end

  def self.kana
    kana = gets.chomp

    until Validator.is_kana?(kana)
      print 'Please enter Hiragana or Katakana: '
      kana = gets.chomp
    end

    kana
  end

  def self.modified_values
    options = {}

    Display.kanji_prompt
    options['character'] = Input.kanji # Class name added for clarity
    Display.strokes_prompt
    options['strokes'] = Input.number
    Display.meaning_prompt
    options['meaning'] = Input.word
    Display.readings_prompt
    options['readings'] = Input.kana

    options
  end
end
