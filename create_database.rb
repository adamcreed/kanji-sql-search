require 'csv'
require_relative 'kanji_database'

class CreateDatabase
  def self.initialize_table
    conn = KanjiDatabase.connect_to_database
    create_table(conn)
    # I feel like the if might too hard to notice if this were one line
    if table_is_empty?(conn)
      seed_database('data/KanjiReadings.txt', conn)
    end

    conn.close
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
      options = {'character' => row[0], 'strokes' => row[1].to_i,
                 'meaning' => row[2], 'readings' => row[3]}

      KanjiDatabase.add_entry(options, conn)
    end
  end
end
