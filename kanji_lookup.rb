require 'pg'
require_relative 'create_database'
require_relative 'kanji_database'
require_relative 'validator'
require_relative 'display'
require_relative 'app'
require_relative 'input'

def main
  CreateDatabase.initialize_table
  loop do
    App.run
  end
end

main if __FILE__ == $PROGRAM_NAME
