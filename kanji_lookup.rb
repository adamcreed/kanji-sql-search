require_relative 'create_database'
require_relative 'app'

def main
  CreateDatabase.initialize_table
  loop do
    App.run
  end
end

main if __FILE__ == $PROGRAM_NAME
