class Products::ImportForm
  include ActiveModel::Model

  attr_accessor :file, :taxonomy_id, :shipping_category_id

  validates :file, presence: true
  validates :taxonomy_id, presence: true
  validates :shipping_category_id, presence: true

  def save
    return false unless valid?

    result = ProductsCsvImporter::Import.new(
      file: file,
      taxonomy: taxonomy_id,
      shipping_category: shipping_category_id
    )
    result.call

    result
  end
end
