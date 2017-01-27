class Display
  def self.instructions
    print 'Please choose kanji lookup (1), edit\add to database (2) ' \
          ', or delete (3), or enter 4 to quit): '
  end

  def self.results(results)
    results.each do |result|
      print "Kanji: #{result['character']}, Strokes: #{result['strokes']}, "
      puts "Meaning: #{result['meaning']}, Readings: #{result['readings']}"
    end
  end

  def self.search_prompt
    print 'Enter a search criteria: '
  end

  def self.kanji_prompt
    print 'Enter the kanji to add/edit: '
  end

  def self.strokes_prompt
    print 'Enter the number of strokes: '
  end

  def self.meaning_prompt
    print 'Enter the meaning: '
  end

  def self.readings_prompt
    print 'Enter the reading: '
  end

  def self.delete_prompt
    print 'Enter the kanji to delete'
  end
end
