require 'pg'
require_relative 'kanji_database'

def main
  conn = connect_to_database
  initialize_table(conn)
  load_from_file('data/KanjiReadings.txt', conn)

  print_prompt
  choice = get_choice(1..4)
  access_database(choice, conn)
end

def print_prompt
  print 'Please choose kanji lookup (1), add to database (2), ' \
        'edit entry (3), or delete (4)): '
end

def access_database(choice, conn)
  case choice
  when 1
    search_database(conn)
  when 2
    add_to_database(conn)
  when 3
    edit_entry(conn)
  when 4
    delete_entry(conn)
  end
end

def search_database(conn)
  print 'Enter a search criteria: '
  search = get_search_criteria

  # There's probably a better way to do this, but this works for now
  results = eval("#{search[:type]}_search(conn, '#{search[:search]}')")

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

def stroke_search(conn, search)
  conn.exec("SELECT * FROM kanji WHERE strokes = #{search}
            ORDER BY readings")
end

def meaning_search(conn, search)
  conn.exec("SELECT * FROM kanji WHERE meaning ~ '#{search}'
            ORDER BY strokes")
end

def readings_search(conn, search)
  # This one kinda works, a proper solution would require some regex voodoo
  # that I'm not getting tonight.
  conn.exec("SELECT * FROM kanji WHERE readings ~ '#{search}'
            ORDER BY strokes")

  #   conn.exec("SELECT * FROM kanji WHERE EXISTS (SELECT readings FROM
  # kanji WHERE '#{search}' ~ '.*(.)*.*');")
end

def kanji_search(conn, search)
  conn.exec("SELECT * FROM kanji WHERE character = '#{search}'
            ORDER BY strokes")
end

def print_results(results)
  results.each do |result|
    print "Kanji: #{result['character']}, Strokes: #{result['strokes']}, "
    puts "Meaning: #{result['meaning']}, Readings: #{result['readings']}"
  end
end

def add_to_database(conn)
  kanji = {}

  kanji[:character] = prompt_for_kanji(conn)
  kanji[:strokes] = prompt_for_strokes
  kanji[:meaning] = prompt_for_meaning
  kanji[:readings] = prompt_for_readings

  add_line(conn, kanji)
end

def prompt_for_kanji(conn)
  print 'Enter the kanji to be added: '

  kanji_with_type = get_kanji(conn, kanji)

  kanji_with_type
end

def get_kanji(conn)
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

def add_line(conn, kanji)
  begin
  conn.exec("INSERT INTO kanji (character, strokes, meaning, readings)
    VALUES ('#{kanji[:character]}', #{kanji[:strokes]},
            '#{kanji[:meaning]}', '#{kanji[:readings]}');")

  rescue PG::UniqueViolation
    puts 'Error: kanji already exists in database, insertion failed.'
  end
end

def edit_entry(conn)
  search_database(conn)

  print 'Enter the kanji you want to edit: '
  selected_entry = get_kanji(conn)

  print 'Enter the field you want to change: '
  selected_field = get_word

  print 'Enter the new value: '
  new_value = gets.chomp

  change_database(conn, selected_entry, selected_field, new_value)
end

def change_database(conn, selected_entry, selected_field, new_value)
  conn.exec("UPDATE kanji SET #{selected_field} = '#{new_value}'
            WHERE character = '#{selected_entry}'")
end

def delete_entry(conn)
  print 'Enter a kanji to delete: '
  selected_entry = get_kanji(conn)

  conn.exec("DELETE FROM kanji WHERE character = '#{selected_entry}'")
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
