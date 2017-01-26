class Kanji
  def initialize(options)
    @id = options.key?('id') ? options['id'] : nil
    @character = options['character']
    @strokes = options['strokes'].to_i
    @meaning = options['meaning']
    @readings = options['readings']
  end

  def save(conn)
   if @id.nil?
     result = conn.exec_params('INSERT INTO kanjis (character, strokes,
                               meaning, readings) VALUES ($1, $2, $3, $4);',
                               [@character, @strokes, @meaning, @readings])

   else
     result = conn.exec_params('UPDATE kanjis SET character = $1, strokes = $2,
                               meaning = $3, readings = $4 WHERE id = $5;',
                               [@character, @strokes, @meaning, @readings, @id])
   end
  end
end
