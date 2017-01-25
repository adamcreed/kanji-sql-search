require 'pg'
require 'csv'

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
