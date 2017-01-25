require 'pg'
require 'csv'
require_relative 'kanji'

class KanjiDatabase
  def self.connect_to_database
    conn = PG.connect(dbname: 'kanji')
    conn.exec("SET client_min_messages TO WARNING;")

    conn
  end

  def self.initialize_table(conn)
    conn.exec("CREATE TABLE IF NOT EXISTS kanji (
      id          serial PRIMARY KEY,
      character   varchar(1) NOT NULL,
      strokes     integer NOT NULL,
      meaning     varchar,
      readings    varchar NOT NULL,
      CONSTRAINT kanji_unique UNIQUE (character)
    );")
  end

  def self.load_from_file(file_path, conn)
    CSV.foreach(file_path) do |row|
      k = Kanji.new(row)
      k.save(conn)
    end
  end
end
