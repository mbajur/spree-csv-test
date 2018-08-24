require 'dry-initializer-rails'

class ProductsCsvImporter::Import < ProductsCsvImporter::Base
  attr_accessor :created_products, :existing_products, :invalid_products,
                :invalid_rows

  CSV_OPTIONS = { headers: true, col_sep: ';' }.freeze

  option :file
  option :taxonomy, model: Spree::Taxonomy
  option :shipping_category, model: Spree::ShippingCategory

  def initialize(*args)
    super(*args)

    @created_products  = []
    @existing_products = []
    @invalid_products  = []
    @invalid_rows      = []
  end

  def call
    CSV.foreach(file.path, CSV_OPTIONS) { |row| handle_row(row) }
  end

  private

  def handle_row(row)
    row_handler =
      ProductsCsvImporter::RowHandler.new(row,
                                          taxons: taxons,
                                          shipping_category: shipping_category)

    status, payload = row_handler.call
    resolve_result(status, payload)
  end

  def resolve_created_result(payload)
    created_products << payload
  end

  def resolve_exists_result(payload)
    existing_products << payload
  end

  def resolve_invalid_result(payload)
    invalid_products << payload
  end

  def resolve_row_invalid_result(payload)
    invalid_rows << payload
  end

  def taxons
    @taxons ||= taxonomy.taxons
  end
end
