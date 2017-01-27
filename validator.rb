class Validator
  def self.is_search_term?(search)
    is_number?(search) or is_word?(search) or
    is_kana?(search) or is_kanji?(search)
  end

  def self.get_search_type(search)
    if is_kanji?(search)
      return 'kanji'
    elsif is_number?(search)
      return 'strokes'
    elsif is_word?(search)
      return 'meaning'
    elsif is_kana?(search)
      return 'readings'
    end
  end

  def self.is_number?(text)
    text.match(/^\d+$/)
  end

  def self.is_word?(text)
    text.match(/^[a-z]+$/i)
  end

  def self.is_kana?(text)
    text.match(/^\p{Hiragana}+$|^\p{Katakana}+$/)
  end

  def self.is_kanji?(text)
    text.match(/^\p{Han}$/)
  end

  def self.is_within_bounds?(input_number, range)
    range.include? input_number.to_i
  end
end
