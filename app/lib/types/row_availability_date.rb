module Types
  include Dry::Types.module

  RowAvailabilityDate = Types::String.constructor do |value|
    date = value.to_s
    ::Time.parse(date)
  rescue ArgumentError
    value
  end
end
