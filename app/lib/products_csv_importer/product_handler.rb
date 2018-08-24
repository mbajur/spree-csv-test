class ProductsCsvImporter::ProductHandler < ProductsCsvImporter::Base
  option :row
  option :taxons
  option :shipping_category, model: Spree::ShippingCategory

  def call
    return result(:exists, existing_product) if existing_product.present?

    product = Spree::Product.new(product_attributes)
    product.taxons = taxons
    product.shipping_category = shipping_category

    if product.save
      manage_stock(product)
      result(:created, product)
    else
      result(:invalid, product)
    end
  end

  private

  def product_attributes
    row.attributes.slice(:name, :description, :price, :slug, :available_on)
  end

  def existing_product
    @existing_product ||= Spree::Product.find_by(slug: row.slug)
  end

  def manage_stock(product)
    return if row.stock_total.zero?
    product.master.stock_items.each do |stock_item|
      Spree::StockMovement.create(quantity: row.stock_total, stock_item: stock_item)
    end
  end
end
