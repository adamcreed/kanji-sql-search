class Kanji
  def initialize(options)
    @character = options[0]
    @strokes = options[1]
    @meaning = options[2]
    @readings = options[3]
  end

  def save(conn)
    begin
      result = conn.exec("INSERT INTO kanji (character, strokes, meaning, readings)
                        VALUES ('#{@character}',
                                '#{@strokes}',
                                $$#{@meaning}$$,
                                '#{@readings}')")

    rescue PG::UniqueViolation
    end
  end
end
