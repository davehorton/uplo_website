class Converter
  def self.decimal_to_cents(decimal_value)
    (decimal_value*100).round
  end
end