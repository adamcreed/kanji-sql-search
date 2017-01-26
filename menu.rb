class Menu
  def self.display_instructions
    print 'Please choose kanji lookup (1), edit\add to database (2) ' \
          ', or delete (3)): '
  end

  def self.search_prompt
    print 'Enter a search criteria: '
  end
end
