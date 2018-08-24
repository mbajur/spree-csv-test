module Types
  include Dry::Types.module

  RowPrice = Types::String.constructor do |value|
    price = value.to_s
    price.tr!(',', '.')

    numeric?(price) && numeric?(price.to_f) ? price.to_f : value
  end

  def self.numeric?(value)
    !Float(value).nil?
  rescue ArgumentError, TypeError
    false
  end
end
