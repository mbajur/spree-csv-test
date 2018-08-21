require 'csv'

Spree::Admin::ProductsController.class_eval do
  def import
    @products_import_form = Products::ImportForm.new
  end

  def import_create
    @products_import_form = Products::ImportForm.new(products_import_params)

    if @products_import_form.valid?
      result = @products_import_form.save

      @created_products  = result.created_products
      @existing_products = result.existing_products
      @invalid_products  = result.invalid_products
      @invalid_rows      = result.invalid_rows

      render :import_results
    else
      render :import
    end
  end

  private

  def products_import_params
    params.require(:products_import).permit(:file, :taxonomy_id, :shipping_category_id)
  end
end
