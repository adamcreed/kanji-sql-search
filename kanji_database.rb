require 'pg'
require 'csv'
require_relative 'kanji'

class KanjiDatabase
  def self.connect_to_database
    conn = PG.connect(dbname: 'kanji')
    conn.exec('SET client_min_messages TO WARNING;')

    conn
  end

  def self.search(search_text, search_type)
    # There's probably a better way to do this, but this works for now
    eval("#{search_type}_search('#{search_text}')")
  end

  def self.kanji_search(search)
    conn = connect_to_database

    results = conn.exec_params("SELECT * FROM kanji WHERE character = $1
              ORDER BY strokes", [search])

    conn.close
    results
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

  def self.check_id(options, conn)
    result = check_for_existing_entry(options['character'], conn)
    if entry_does_not_exist?(result)
      nil
    else
      result[0]['id']
    end
  end

  def self.check_for_existing_entry(character, conn)
    conn.exec_params('SELECT * FROM kanji WHERE character = $1', [character])
  end

  def self.entry_does_not_exist?(result)
    result.num_tuples.zero?
  end

  def self.delete_entry(character)
    conn = connect_to_database
    conn.exec_params('DELETE FROM kanji WHERE character = $1;', [character])
    conn.close
  end
end
