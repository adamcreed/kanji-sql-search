require 'pg'
require_relative 'kanji_database'

def main
  conn = KanjiDatabase.connect_to_database
  KanjiDatabase.initialize_table(conn)
  KanjiDatabase.load_from_file('data/KanjiReadings.txt', conn)
  conn.close

  print_prompt
  choice = get_choice(1..4)
  access_database(choice)
end

def print_prompt
  print 'Please choose kanji lookup (1), add to database (2), ' \
        'edit entry (3), or delete (4)): '
end

def access_database(choice)
  case choice
  when 1
    search_database
  when 2
    add_to_database
  when 3
    edit_entry
  when 4
    delete_entry
  end
end

def search_database
  print 'Enter a search criteria: '
  search = get_search_criteria

  # There's probably a better way to do this, but this works for now
  results = eval("#{search[:type]}_search('#{search[:search]}')")

  print_results(results)
end

def get_search_criteria
  search = gets.chomp

  until search_with_type = is_number?(search) or search_with_type = is_word?(search) \
        or search_with_type = is_kana?(search) or search_with_type = is_kanji?(search)
    print 'Please enter a meaning, kanji, reading, or stroke count: '
    search = gets.chomp
  end

  search_with_type
end

def stroke_search(search)
  conn = KanjiDatabase.connect_to_database

  results = conn.exec_params("SELECT * FROM kanji WHERE strokes = $1
                      ORDER BY readings", [search])

  conn.close
  results
end

def meaning_search(search)
  conn = KanjiDatabase.connect_to_database

  results = conn.exec_params("SELECT * FROM kanji WHERE meaning ~ $1
                      ORDER BY strokes", [search])

  conn.close
  results
end

def readings_search(search)
  conn = KanjiDatabase.connect_to_database

  # This one kinda works, a proper solution would require some regex voodoo
  # that I'm not getting tonight.
  results = conn.exec_params("SELECT * FROM kanji WHERE readings ~ $1
                      ORDER BY strokes", [search])

  #   conn.exec("SELECT * FROM kanji WHERE EXISTS (SELECT readings FROM
  # kanji WHERE '#{search}' ~ '.*(.)*.*');")

  conn.close
  results
end

def kanji_search(search)
  conn = KanjiDatabase.connect_to_database

  results = conn.exec_params("SELECT * FROM kanji WHERE character = $1
            ORDER BY strokes", [search])

  conn.close
  results
end

def print_results(results)
  results.each do |result|
    print "Kanji: #{result['character']}, Strokes: #{result['strokes']}, "
    puts "Meaning: #{result['meaning']}, Readings: #{result['readings']}"
  end
end

def add_to_database
  kanji = {}

  kanji[:character] = prompt_for_kanji
  kanji[:strokes] = prompt_for_strokes
  kanji[:meaning] = prompt_for_meaning
  kanji[:readings] = prompt_for_readings

  add_line(kanji)
end

def prompt_for_kanji
  print 'Enter the kanji to be added: '

  kanji_with_type = get_kanji

  kanji_with_type
end

def get_kanji
  kanji = gets.chomp

  until kanji_with_type = is_kanji?(kanji)
    print 'Please enter a kanji: '
    kanji = gets.chomp
  end

  kanji_with_type[:search]
end

def prompt_for_strokes
  print 'Enter the number of strokes: '

  strokes_with_type = get_strokes

  strokes_with_type
end

def get_strokes
  strokes = gets.chomp

  until strokes_with_type = is_number?(strokes)
    print 'Please enter a number: '
    strokes = gets.chomp
  end

  strokes_with_type[:search]
end

def prompt_for_meaning
  print 'Enter the meaning: '

  meaning_with_type = get_word

  meaning_with_type
end

def get_word
  word = gets.chomp

  until word_with_type = is_word?(word)
    print 'Please enter a word: '
    word = gets.chomp
  end

  word_with_type[:search]
end

def prompt_for_readings
  print 'Enter the reading: '

  readings_with_type = get_readings

  readings_with_type
end

def get_readings
  readings = gets.chomp

  until readings_with_type = is_kana?(readings)
    print 'Please enter hiragana or katakana: '
    readings = gets.chomp
  end

  readings_with_type[:search]
end

def add_line(kanji)
  conn = KanjiDatabase.connect_to_database

  begin
  conn.exec_params("INSERT INTO kanji (character, strokes, meaning, readings)
                    VALUES ($1, $2, $3, $4);",
                    [kanji[:character], kanji[:strokes],
                    kanji[:meaning], kanji[:readings]])

  rescue PG::UniqueViolation
    puts 'Error: kanji already exists in database, insertion failed.'
  end

  conn.close
end

def edit_entry
  search_database

  print 'Enter the kanji you want to edit: '
  selected_entry = get_kanji

  print 'Enter the field you want to change: '
  selected_field = get_word

  print 'Enter the new value: '
  new_value = gets.chomp

  change_database(selected_entry, selected_field, new_value)
end

def change_database(selected_entry, selected_field, new_value)
  conn = KanjiDatabase.connect_to_database
  selected_field = conn.quote_ident(selected_field)

  conn.exec_params("UPDATE kanji SET #{selected_field} = $1
                    WHERE character = $2;",
                    [new_value, selected_entry])

  conn.close
end

def delete_entry
  print 'Enter a kanji to delete: '
  selected_entry = get_kanji

  conn = KanjiDatabase.connect_to_database
  conn.exec_params("DELETE FROM kanji WHERE character = $1;", [selected_entry])
  conn.close
end

def is_number?(text)
  text.match(/^\d+$/) ? {search: text, type: 'stroke'} : false
end

def is_word?(text)
  text.match(/^[a-z]+$/i) ? {search: text, type: 'meaning'} : false
end

def is_kana?(text)
  if text.match(/^\p{Hiragana}+$|^\p{Katakana}+$/)
    {search: text, type: 'readings'}
  else
    false
  end
end

def is_kanji?(text)
  text.match(/^\p{Han}$/) ? {search: text, type: 'kanji'} : false
end

def get_choice(range)
  choice = gets.chomp

  until is_within_bounds?(choice, range)
    print "Please enter #{range.min}-#{range.max}: "
    choice = gets.chomp
  end

  choice.to_i
end

def is_within_bounds?(input_number, range)
  range.include? input_number.to_i
end

main if __FILE__ == $PROGRAM_NAME
