require_relative 'display'
require_relative 'input'
require_relative 'validator'


class App
  def self.run
    Display.instructions
    access_database(Input.choice(1..4))
  end

  def self.access_database(choice)
    case choice
    when 1
      search_database
    when 2
      modify_database
    when 3
      delete_entry
    when 4
      exit
    end
  end

  def self.search_database
    Display.search_prompt
    search_text = Input.search_term
    search_type = Validator.get_search_type(search_text)
    results = KanjiDatabase.search(search_text, search_type)
    Display.results(results)
  end

  def self.modify_database
    options = Input.modified_values
    conn = KanjiDatabase.connect_to_database
    options['id'] = KanjiDatabase.check_id(options, conn)
    KanjiDatabase.add_entry(options, conn)
    conn.close
  end

  def self.delete_entry
    Display.delete_prompt
    character = Input.kanji
    KanjiDatabase.delete_entry(character)
  end
end
