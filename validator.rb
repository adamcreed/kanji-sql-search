class Validator
  def self.is_number?(text)
    text.match(/^\d+$/) ? {search: text, type: 'stroke'} : false
  end

  def self.is_word?(text)
    text.match(/^[a-z]+$/i) ? {search: text, type: 'meaning'} : false
  end

  def self.is_kana?(text)
    if text.match(/^\p{Hiragana}+$|^\p{Katakana}+$/)
      {search: text, type: 'readings'}
    else
      false
    end
  end

  def self.is_kanji?(text)
    text.match(/^\p{Han}$/) ? {search: text, type: 'kanji'} : false
  end

  def self.is_within_bounds?(input_number, range)
    range.include? input_number.to_i
  end
end
