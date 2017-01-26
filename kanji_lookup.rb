require 'pg'
require_relative 'kanji_database'
require_relative 'validator'
require_relative 'menu'
require_relative 'app'

def main
  KanjiDatabase.initialize_table
  Menu.display_instructions
  choice = Menu.make_choice(1..3)
  App.access_database(choice)
end


def check_id(options, conn)
  result = KanjiDatabase.check_for_existing_entry(options['character'], conn)
  if KanjiDatabase.entry_does_not_exist?(result)
    nil
  else
    result[0]['id']
  end
end

def prompt_for_kanji
  print 'Enter the kanji to add/edit: '

  get_kanji
end

def get_kanji
  kanji = gets.chomp

  until kanji_with_type = Validator.is_kanji?(kanji)
    print 'Please enter a kanji: '
    kanji = gets.chomp
  end

  kanji_with_type[:search]
end

def prompt_for_strokes
  print 'Enter the number of strokes: '

  get_strokes
end

def get_strokes
  strokes = gets.chomp

  until strokes_with_type = Validator.is_number?(strokes)
    print 'Please enter a number: '
    strokes = gets.chomp
  end

  strokes_with_type[:search]
end

def prompt_for_meaning
  print 'Enter the meaning: '

  get_word
end

def get_word
  word = gets.chomp

  until word_with_type = Validator.is_word?(word)
    print 'Please enter a word: '
    word = gets.chomp
  end

  word_with_type[:search]
end

def prompt_for_readings
  print 'Enter the reading: '

  get_readings
end

def get_readings
  readings = gets.chomp

  until readings_with_type = Validator.is_kana?(readings)
    print 'Please enter hiragana or katakana: '
    readings = gets.chomp
  end

  readings_with_type[:search]
end

def delete_entry
  print 'Enter a kanji to delete: '
  KanjiDatabase.delete_entry(get_kanji)
end

def make_choice(range)
  choice = gets.chomp

  until Validator.is_within_bounds?(choice, range)
    print "Please enter #{range.min}-#{range.max}: "
    choice = gets.chomp
  end

  choice.to_i
end

main if __FILE__ == $PROGRAM_NAME
