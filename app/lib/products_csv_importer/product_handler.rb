class ProductsCsvImporter::ProductHandler < ProductsCsvImporter::Base
  # Options are not really used for validation product attribute presence. They
  # are here just to filter the incoming data. Real validation is done using
  # Schema.
  option :name, optional: true
  option :description, optional: true
  option :price, proc(&:to_f), optional: true
  option :slug, optional: true
  option :availability_date, optional: true, as: :available_on # @todo rename it to available_on
  option :taxons, optional: true
  option :stock_total, proc(&:to_i), default: proc { 0 }, optional: true
  option :shipping_category_id

  Schema = Dry::Validation.Schema do
    required(:name).filled
    required(:price).filled
    required(:shipping_category_id).filled
  end

  def call
    return result(:exists, existing_product) if existing_product.present?
    product = Spree::Product.new(product_attributes)

    if product.valid?
      product.save!
      manage_stock(product)

      result(:created, product)
    else
      result(:invalid, product)
    end
  end

  def params_valid?
    Schema.call(product_attributes).success?
  end

  def params_full_errors
    Schema.call(product_attributes).messages(full: true).values.flatten
  end

  private

  # @todo: Consider using to_hash ?
  def product_attributes
    attributes.slice(:name, :description, :price, :slug, :available_on,
                     :shipping_category_id, :taxons)
  end

  def existing_product
    @existing_product ||= Spree::Product.find_by(slug: slug)
  end

  def manage_stock(product)
    return if stock_total.zero?

    product.master.stock_items.each do |stock_item|
      Spree::StockMovement.create(quantity: stock_total, stock_item: stock_item)
    end
  end
end
