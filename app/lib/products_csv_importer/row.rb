class ProductsCsvImporter::Row
  extend Dry::Initializer

  option :name, optional: true
  option :description, optional: true
  option :price, Types::RowPrice, optional: true
  option :availability_date, Types::RowAvailabilityDate, optional: true, as: :available_on
  option :slug, optional: true
  option :stock_total, Types::RowStockTotal, optional: true
  option :category, optional: true

  Schema = Dry::Validation.Schema do
    required(:name).filled(type?: String)
    required(:price).filled(type?: Float, gt?: 0.0)
    required(:stock_total).filled(type?: Integer, gt?: 0)
    optional(:available_on).maybe(type?: Time)
  end

  def valid?
    Schema.call(attributes).success?
  end

  def full_errors
    Schema.call(attributes).errors(full: true).values.flatten
  end

  def attributes
    __dry_initializer_config__.attributes(self)
  end
end
