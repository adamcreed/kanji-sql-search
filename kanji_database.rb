require 'pg'
require 'csv'
require_relative 'kanji'

class KanjiDatabase
  def self.initialize_table
    conn = connect_to_database
    create_table(conn)
    # I feel like the if might too hard to notice if this were one line
    if table_is_empty?(conn)
      seed_database('data/KanjiReadings.txt', conn)
    end

    conn.close
  end

  def self.connect_to_database
    conn = PG.connect(dbname: 'kanji')
    conn.exec('SET client_min_messages TO WARNING;')

    conn
  end

  def self.create_table(conn)
    conn.exec("CREATE TABLE IF NOT EXISTS kanji (
      id          serial PRIMARY KEY,
      character   varchar(1) NOT NULL,
      strokes     integer NOT NULL,
      meaning     varchar,
      readings    varchar NOT NULL,
      CONSTRAINT kanji_unique UNIQUE (character)
    );")
  end

  def self.table_is_empty?(conn)
    row_count = conn.exec('SELECT COUNT(*) FROM kanji;')
    row_count[0]['count'].to_i == 0
  end

  def self.seed_database(file_path, conn)
    CSV.foreach(file_path) do |row|
      add_entry(row, conn)
    end
  end

  def self.add_entry(row, conn)
    result = check_for_existing_entry(row[0], conn)
    if entry_does_not_exist?(result)
      k = create_new_entry(row, conn)
    else
      k = load_existing_entry(result)
    end
    k.save(conn)
  end

  def self.check_for_existing_entry(character, conn)
    conn.exec_params('SELECT * FROM kanji WHERE character = $1', [character])
  end

  def self.entry_does_not_exist?(result)
    result.num_tuples.zero?
  end

  def self.create_new_entry(row, conn)
    options = {'character' => row[0], 'strokes' => row[1].to_i,
               'meaning' => row[2], 'readings' => row[3]}
    Kanji.new(options)
  end

  def self.load_existing_entry(result)
    Kanji.new(result[0])
  end

  def self.search(search_text)
    # There's probably a better way to do this, but this works for now
    results = eval("#{search_text[:type]}_search('#{search_text[:search]}')")

    print_results(results)
  end

  def self.is_valid_search?(search)
    Validator.is_number?(search) or Validator.is_word?(search) or
    Validator.is_kana?(search) or Validator.is_kanji?(search)
  end

  def self.stroke_search(search)
    conn = connect_to_database

    results = conn.exec_params("SELECT * FROM kanji WHERE strokes = $1
                        ORDER BY readings", [search])

    conn.close
    results
  end

  def self.meaning_search(search)
    conn = connect_to_database

    results = conn.exec_params("SELECT * FROM kanji WHERE meaning ~ $1
                        ORDER BY strokes", [search])

    conn.close
    results
  end

  def self.readings_search(search)
    conn = connect_to_database

    results = conn.exec_params("SELECT * FROM kanji WHERE
                               REPLACE(readings, '.', '')
                               LIKE CONCAT(CONCAT('%', $1::varchar), '%')",
                               [search])

    conn.close
    results
  end

  def self.kanji_search(search)
    conn = connect_to_database

    results = conn.exec_params("SELECT * FROM kanji WHERE character = $1
              ORDER BY strokes", [search])

    conn.close
    results
  end

  def self.delete_entry(selected_entry)
    conn = connect_to_database
    conn.exec_params('DELETE FROM kanji WHERE character = $1;', [selected_entry])
    conn.close
  end
end
