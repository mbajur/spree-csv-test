class ProductsCsvImporter::RowHandler < ProductsCsvImporter::Base
  param :row, (proc { |v| v.to_h.symbolize_keys })
  option :taxons
  option :shipping_category

  def call
    product_handler = ProductsCsvImporter::ProductHandler.new(product_attributes)

    unless product_handler.params_valid?
      res = FailedRowResult.new(row, product_handler.params_full_errors)
      return result(:row_invalid, res)
    end

    status, payload = product_handler.call
    resolve_result(status, payload)
  end

  private

  def product_attributes
    row.merge(
      shipping_category_id: shipping_category.id,
      taxons: parsed_product_taxons,
      availability_date: parsed_availability_date,
      price: parsed_price
    )
  end

  def parsed_product_taxons
    return [] unless row[:category]
    taxons.select { |t| t.name == row[:category] }
  end

  # @todo: there should be probably datetime validation involved in here instead
  # of rescuing ArgumentError
  def parsed_availability_date
    return nil unless row[:availability_date]
    Time.parse(row[:availability_date])
  rescue ArgumentError
    nil
  end

  def parsed_price
    return nil unless row[:price]
    row[:price].gsub(',', '.')
  end

  def resolve_exists_result(payload)
    logger.info "Product exists: #{payload.name}"
    result(:exists, payload)
  end

  def resolve_created_result(payload)
    logger.info "Product created! #{payload.name}"
    result(:created, payload)
  end

  def resolve_invalid_result(payload)
    logger.warn "Product is invalid! #{payload.errors.full_messages}"
    result(:invalid, payload)
  end

  FailedRowResult = Struct.new(:content, :errors) do
    def to_csv
      CSV.generate { |csv| csv << content.values }
    end
  end
end
