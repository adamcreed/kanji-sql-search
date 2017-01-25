require 'pg'
require 'csv'

def main
  conn = connect_to_database
  initialize_table(conn)
  load_from_file('data/KanjiReadings.txt', conn)

  print_prompt
  choice = get_choice(1..2)
  access_database(choice, conn)
end

def connect_to_database
  conn = PG.connect(dbname: 'kanji')
  conn.exec("SET client_min_messages TO WARNING;")

  conn
end

def initialize_table(conn)
  conn.exec("CREATE TABLE IF NOT EXISTS kanji (
    id          serial PRIMARY KEY,
    character   varchar(1) NOT NULL,
    strokes     integer NOT NULL,
    meaning     varchar,
    readings    varchar NOT NULL,
    CONSTRAINT kanji_unique UNIQUE (character)
  );")
end

def load_from_file(file_path, conn)
  CSV.foreach(file_path) do |row|
    add_row(row, conn)
  end
end

def add_row(row, conn)
  current_kanji = row[0]
  current_strokes = row[1]
  current_meaning = row[2]
  current_readings = row[3]

  begin
    result = conn.exec("INSERT INTO kanji (character, strokes, meaning, readings)
                      VALUES ('#{current_kanji}',
                              '#{current_strokes}',
                              $$#{current_meaning}$$,
                              '#{current_readings}')")

  rescue PG::UniqueViolation
  end
end

def print_prompt
  print 'Please choose kanji lookup (1) or add to database (2): '
end

def access_database(choice, conn)
  if choice == 1
    print 'Enter your search criteria: '
    search_database(conn)
  else
    add_to_database(conn)
  end
end

def search_database(conn)
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
  kanji[:character] = get_kanji(conn)
  kanji[:strokes] = get_strokes
  kanji[:meaning] = get_meaning
  kanji[:readings] = get_readings

  add_line(conn, kanji)
end

def get_kanji(conn)
  print 'Enter the kanji to be added: '
  kanji = gets.chomp

  until kanji_with_type = is_kanji?(kanji)
    print 'Please enter a kanji: '
    kanji = gets.chomp
  end

  p kanji_with_type[:search]
end

def get_strokes
  print 'Enter the number of strokes: '
  strokes = gets.chomp

  until strokes_with_type = is_number?(strokes)
    print 'Please enter a number: '
    strokes = gets.chomp
  end

  p strokes_with_type[:search]
end

def get_meaning
  print 'Enter the meaning: '
  meaning = gets.chomp

  until meaning_with_type = is_word?(meaning)
    print 'Please enter a word: '
    meaning = gets.chomp
  end

  p meaning_with_type[:search]
end

def get_readings
  print 'Enter the reading: '
  readings = gets.chomp

  until readings_with_type = is_kana?(readings)
    print 'Please enter hiragana or katakana: '
    readings = gets.chomp
  end

  p readings_with_type[:search]
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
