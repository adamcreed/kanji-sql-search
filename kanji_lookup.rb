require 'pg'
require_relative 'kanji_database'
require_relative 'validator'

def main
  KanjiDatabase.initialize_table
  display_instructions
  choice = make_choice(1..3)
  access_database(choice)
end

def display_instructions
  print 'Please choose kanji lookup (1), edit\add to database (2) ' \
        ', or delete (3)): '
end

def access_database(choice)
  case choice
  when 1
    search_database
  when 2
    modify_database
  when 3
    delete_entry
  end
end

def search_database
  print 'Enter a search criteria: '
  search_text = get_search_criteria
  KanjiDatabase.search(search_text)
end

def get_search_criteria
  search = gets.chomp

  until search_with_type = KanjiDatabase.is_valid_search?(search)
    print 'Please enter a meaning, kanji, reading, or stroke count: '
    search = gets.chomp
  end

  search_with_type
end

def print_results(results)
  results.each do |result|
    print "Kanji: #{result['character']}, Strokes: #{result['strokes']}, "
    puts "Meaning: #{result['meaning']}, Readings: #{result['readings']}"
  end
end

def modify_database
  options = get_modified_values
  conn = KanjiDatabase.connect_to_database
  options['id'] = check_id(options, conn)
  k = Kanji.new(options)
  k.save(conn)
  conn.close
end

# I'm not super into this name, but don't got anything better at the moment.
def get_modified_values
  options = {}
  options['character'] = prompt_for_kanji
  options['strokes'] = prompt_for_strokes
  options['meaning'] = prompt_for_meaning
  options['readings'] = prompt_for_readings

  options
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
