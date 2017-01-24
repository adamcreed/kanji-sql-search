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
    kanji       varchar(1) NOT NULL,
    strokes     integer NOT NULL,
    meaning     varchar,
    readings    varchar NOT NULL,
    CONSTRAINT kanji_unique UNIQUE (kanji)
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
    result = conn.exec("INSERT INTO kanji (kanji, strokes, meaning, readings)
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
  results = eval("#{search[:type]}_search(conn, #{search[:search]})")

  print_results(results)
end

def get_search_criteria
  search = gets.chomp

  until search = is_number?(search) or is_word?(search) \
        or is_kana?(search) or is_kanji?(search)
    print 'Please enter a meaning, kanji, reading, or stroke count: '
    search = gets.chomp
  end

  search
end

def stroke_search(conn, search)
  conn.exec("SELECT * FROM kanji WHERE strokes = #{search}")
end

def print_results(results)
  results.each do |result|
    print "Kanji: #{result['kanji']}, Strokes: #{result['strokes']}, " \
    puts "Meaning: #{result['meaning']}, Readings: #{result['readings']}"
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

def add_to_database(conn)
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
