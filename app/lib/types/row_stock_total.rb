module Types
  include Dry::Types.module

  RowStockTotal = Types::String.constructor do |value|
    value.present? ? value.to_s.to_i : nil
  end
end
