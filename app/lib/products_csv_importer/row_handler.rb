class ProductsCsvImporter::RowHandler < ProductsCsvImporter::Base
  param :row, proc { |v| v.to_h.symbolize_keys }
  option :taxons
  option :shipping_category, model: Spree::ShippingCategory

  def call
    product_handler = ProductsCsvImporter::ProductHandler.new(
      row: serialized_row,
      shipping_category: shipping_category,
      taxons: matched_taxons
    )

    unless serialized_row.valid?
      res = FailedRowResult.new(row, serialized_row.full_errors)
      return result(:row_invalid, res)
    end

    status, payload = product_handler.call
    resolve_result(status, payload)
  end

  private

  def serialized_row
    @serialized_row ||= ProductsCsvImporter::Row.new(row.compact)
  end

  def matched_taxons
    return [] unless serialized_row.category.presence
    taxons.select { |t| t.name == serialized_row.category }
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
