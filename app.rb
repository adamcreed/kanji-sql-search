class App
  def self.access_database(choice)
    case choice
    when 1
      search_database
    when 2
      modify_database
    when 3
      delete_entry
    end
  end

  def self.search_database
    Menu.search_prompt
    search_text = get_search_criteria
    KanjiDatabase.search(search_text)
  end

  def self.get_search_criteria
    search = gets.chomp

    until search_with_type = KanjiDatabase.is_valid_search?(search)
      print 'Please enter a meaning, kanji, reading, or stroke count: '
      search = gets.chomp
    end

    search_with_type
  end

  def self.print_results(results)
    results.each do |result|
      print "Kanji: #{result['character']}, Strokes: #{result['strokes']}, "
      puts "Meaning: #{result['meaning']}, Readings: #{result['readings']}"
    end
  end

  def self.modify_database
    options = get_modified_values
    conn = KanjiDatabase.connect_to_database
    options['id'] = check_id(options, conn)
    k = Kanji.new(options)
    k.save(conn)
    conn.close
  end

  # I'm not super into this name, but don't got anything better at the moment.
  def self.get_modified_values
    options = {}
    options['character'] = prompt_for_kanji
    options['strokes'] = prompt_for_strokes
    options['meaning'] = prompt_for_meaning
    options['readings'] = prompt_for_readings

    options
  end
end
