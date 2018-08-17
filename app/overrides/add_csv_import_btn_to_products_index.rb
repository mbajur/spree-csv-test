Deface::Override.new(
  virtual_path: 'spree/admin/products/index',
  name: 'add_csv_import_btn_to_products_index',
  insert_before: "erb[loud]:contains('admin_new_product')",
  text: "
    <%= render 'spree/admin/shared/import_products_button' %>
  ")
